import time
import sys
import os

# here's the obvious part!
sys.stdin.close()
sys.stdout.close()
sys.stderr.close()

# this is pretty obscure!
os.close(0)
os.close(1)
os.close(2)


large_string = " " * (1024 ** 3)

i = 0
f = open("output.log", "w")
f.close()
while True:
	f = open("output.log", "a")
	f.write(str(i) + "\n")
	f.close()

	i = i + 1
	time.sleep(1)
