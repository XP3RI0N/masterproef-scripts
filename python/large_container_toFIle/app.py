import time

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
