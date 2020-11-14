#!/usr/bin/env bash
set -e

#
# This script enabled IPv4 NAT on wall1 and wall2, physical and virtual machines.
# It also persist this change on ubuntu/debian, so that it survives a machine reboot.
#
# This will off course not work on any distro. It has been tested on the default ubuntu/debian images.
# Patches to make it work on other images are always welcome.
#
# This script returns output that can be used by ansible.
#

SETUP_IGENT_VPN=1

if [[ $EUID -ne 0 ]]
then
    echo "{ \"failed\": true, \"msg\": \"This script should be run using sudo or as the root user\" }"
    exit 1
fi

GW=$(route -n | grep '^0.0.0.0' | grep UG | awk '{print $2}')

WALL=$(hostname | sed -e 's/.*\(wall[1-2]\).ilabt.iminds.be$/\1/')

SYSTEMD_NETWORK_CONF_FILE=""

init_systemd_network() {
    for emunetconf in /run/systemd/network/*.network
    do
       if grep -q 'Emulab control net search' "$emunetconf"
       then
          SYSTEMD_NETWORK_CONF_FILE="/etc/systemd/network/$(basename $emunetconf)"
          if [ ! -e "${SYSTEMD_NETWORK_CONF_FILE}" ]
          then
             cp "$emunetconf" "${SYSTEMD_NETWORK_CONF_FILE}"
             echo >> "${SYSTEMD_NETWORK_CONF_FILE}"
             echo "### DEFAULT GATEWAY ###" >> "${SYSTEMD_NETWORK_CONF_FILE}"
             echo >> "${SYSTEMD_NETWORK_CONF_FILE}"
             echo "### OTHER ROUTES ###" >> "${SYSTEMD_NETWORK_CONF_FILE}"
             echo >> "${SYSTEMD_NETWORK_CONF_FILE}"
             echo "### OTHER CONFIG ###" >> "${SYSTEMD_NETWORK_CONF_FILE}"
             echo >> "${SYSTEMD_NETWORK_CONF_FILE}"
          fi
       fi
    done
}

init_etc_network_interfaces() {
    if [ -e /etc/network/interfaces ]
    then
       sed -e '/^iface cnet inet manual$/a    #INSERT_BEFORE_THIS' -i /etc/network/interfaces
    fi
}

cleanup_etc_network_interfaces() {
    if [ -e /etc/network/interfaces ]
    then
        sed -e '/^#INSERT_BEFORE_THIS/d' -i /etc/network/interfaces
    fi
}

# (full disclosure: not my own bash-foo)
mask2cdr ()
{
   # Assumes there's no "255." after a non-255 byte in the mask
   local x=${1##*255.}
   set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
   x=${1%%$3*}
   echo $(( $2 + (${#x}/4) ))
}

change_default_gateway() {
    new_gw=$1

    #Add now
    route del default gw ${GW} && route add default gw ${new_gw}

    #Add on reboot /etc/network/interfaces method
    if [ -e /etc/network/interfaces ]
    then
        # In old version, this had mistakenly: -e"/^iface cnet inet manual$/a \ \ \ \ pre-up route del default gw ${GW}"\
        sed -i -e"/#INSERT_BEFORE_THIS/i \ \ \ \ post-up route del default; route add default gw ${new_gw}"\
                /etc/network/interfaces
    fi

    #Add on reboot /etc/systemd/network method
    if [ -n "${SYSTEMD_NETWORK_CONF_FILE}" ]
    then
        sed -e "/### DEFAULT GATEWAY ###/a [Route]\nGateway=${new_gw}\nGatewayOnlink=yes\n\n" -i "${SYSTEMD_NETWORK_CONF_FILE}"
        sed -e "/\[DHCP\]/a UseRoutes=no" -i "${SYSTEMD_NETWORK_CONF_FILE}"
    fi

    #TODO
    # check if netplan is used, and add something that generates the correct systemd.network config.
    # Problem: changing gateway after dhcp seems not to work.
    # Example working config:
    #   network:
    #    version: 2
    #    renderer: networkd
    #    ethernets:
    #      ens160:
    #        dhcp4: false
    #        #dhcp4: true   # Sadly, netplan doesn't generate the systemd.network config that correctly changes dhpc gateway
    #        addresses: 
    #           - 10.2.46.250/20
    #        gateway4: 10.2.47.253 
    #        nameservers:
    #            addresses:
    #              - 10.2.32.1
    #            search:
    #              - wall2.ilabt.iminds.be
    #        routes:
    #           #- to: 0.0.0.0/0  # this after dhcp gateway attempt doesn't work either :-/
    #           #  via: 10.2.47.253
    #           - to: 192.168.126.0/24 
    #             via: 10.2.47.254
    #           - to: 157.193.135.0/24 
    #             via: 10.2.47.254
    #           - to: 157.193.215.0/24 
    #             via: 10.2.47.254
    #           - to: 157.193.214.0/24 
    #             via: 10.2.47.254
    #           - to: 10.2.0.0/20 
    #             via: 10.2.47.254
    #           - to: 10.11.0.0/16 
    #             via: 10.2.47.254
}

add_route() {
    target=$1
    netmask=$2
    route_gw=$3

    #Add now
    route add -net ${target} netmask ${netmask} gw ${route_gw}

    #Add on reboot
    if [ -e /etc/network/interfaces ]
    then
        sed -i -e"/#INSERT_BEFORE_THIS$/i \ \ \ \ post-up route add -net ${target} netmask ${netmask} gw ${route_gw}" /etc/network/interfaces
    fi

    #Add on reboot /etc/systemd/network method
    if [ -n "${SYSTEMD_NETWORK_CONF_FILE}" ]
    then
        prefix_len=`mask2cdr ${netmask}`
        sed -e "/### OTHER ROUTES ###/a [Route]\nGateway=${route_gw}\nDestination=${target}/${prefix_len}\nGatewayOnlink=yes\n\n" -i "${SYSTEMD_NETWORK_CONF_FILE}"
    fi
}

if [[ "$GW" = "10.2.15.253" ]] #Physical wall1-machines with IPv4 already set
then
    echo "{ \"changed\": false, \"msg\": \"Already set up IPv4 NAT for wall1 physical node\" }"
    exit 0
elif [[ "$GW" = "10.2.47.253" ]] #Physical wall2-machines with IPv4 already set
then
    echo "{ \"changed\": false, \"msg\": \"Already set up IPv4 NAT for wall2 physical node\" }"
    exit 0
elif [[ "$GW" = "172.16.0.2" ]] #Virtual machines with IPv4 already set
then
    echo "{ \"changed\": false, \"msg\": \"Already set up IPv4 NAT for wall virtual machine\" }"
    exit 0
elif [[ "$GW" = "10.2.15.254" ]] #Physical wall1-machines
then
    init_systemd_network
    init_etc_network_interfaces
    change_default_gateway '10.2.15.253'
    add_route '10.11.0.0' '255.255.0.0' $GW
    add_route '10.2.32.0' '255.255.240.0' $GW
    cleanup_etc_network_interfaces
    echo "{ \"changed\": true, \"msg\": \"Succesfully setup IPv4 NAT for wall1 physical node\" }"
elif [[ "$GW" = "172.16.0.1" && "${WALL}" = "wall1" ]] #Virtual wall1-machines
then
    init_systemd_network
    init_etc_network_interfaces
    add_route '10.2.0.0' '255.255.240.0' $GW
    change_default_gateway '172.16.0.2'
    cleanup_etc_network_interfaces
    echo "{ \"changed\": true, \"msg\": \"Succesfully setup IPv4 NAT for wall1 virtual machine\" }"
elif [[ "$GW" = "10.2.47.254" ]] #Physical wall2-machines
then
    init_systemd_network
    init_etc_network_interfaces
    change_default_gateway '10.2.47.253'
    add_route '10.11.0.0' '255.255.0.0' $GW
    add_route '10.2.0.0' '255.255.240.0' $GW
    cleanup_etc_network_interfaces
    echo "{ \"changed\": true, \"msg\": \"Succesfully setup IPv4 NAT for wall2 physical node\" }"
elif [[ "$GW" = "172.16.0.1" && "${WALL}" = "wall2" ]] #Virtual wall2-machines
then
    init_systemd_network
    init_etc_network_interfaces
    add_route '10.2.32.0' '255.255.240.0' $GW
    change_default_gateway '172.16.0.2'
    cleanup_etc_network_interfaces
    echo "{ \"changed\": true, \"msg\": \"Succesfully setup IPv4 NAT for wall2 virtual machine\" }"
else
    echo "{ \"failed\": true, \"changed\": false, \"msg\": \"Failed to detect testbed with GW=${GW}\" }"
    exit 1
fi

if [[ "$SETUP_IGENT_VPN" ]]
then
    add_route '157.193.214.0' '255.255.255.0' $GW
    add_route '157.193.215.0' '255.255.255.0' $GW
    add_route '157.193.135.0' '255.255.255.0' $GW
    add_route '192.168.126.0' '255.255.255.0' $GW
fi
