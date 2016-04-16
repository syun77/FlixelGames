#!/usr/bin/env python
# -*- coding: utf-8 -*-


class Stack:
	""" スタッククラス """
	def __init__(self):
		self.stack = []
	def size(self):
		return len(self.stack)
	def push(self, var):
		self.stack.append(var)
	def pop(self):
		return self.stack.pop()
	def top(self):
		return self.stack[-1]
	def iterator(self):
		return self.stack[:]
	def isEmpty(self):
		return self.size() == 0

class Queue:
	""" キュークラス """
	def __init__(self):
		self.queue = []
	def size(self):
		return len(self.queue)
	def push(self, var):
		self.queue.append(var)
	def pop(self):
		return self.queue.pop(0)
	def iterator(self):
		return self.queue[:]


def main():
	stack = Stack()
	stack.push(2)
	stack.push(3)
	stack.push(5)

	while not(stack.isEmpty()):
		print stack.pop()
if(__name__ == "__main__"):
	main()
