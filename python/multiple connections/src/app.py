from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello world!'

@app.route('/', methods=['POST'])
def sortNumbers():
	numbers = request.json['numbers']
	bubbleSort(numbers)
	return jsonify(numbers)

def bubbleSort(alist):
	for passnum in range(len(alist)-1,0,-1):
		for i in range(passnum):
			if alist[i]>alist[i+1]:
				temp = alist[i]
				alist[i] = alist[i+1]
				alist[i+1] = temp

count = 0

@app.route('/count', methods=['GET'])
def counter():
	global count
	count += 1
	return "The counter is: %s" % count

