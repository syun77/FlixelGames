#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 構文木数値クラス """
from node import Node
from code import Code

class Integer(Node):
	def __init__(self, value):
		try:
			self.value = int(value)
		except:
			raise Exception("Error: Illigal parameter. ->%s"%value)
	def getValue(self):
		return self.value
	def run(self, writer):
		""" 数値命令書き込み
		# [opecode, 数値]
		# [1,       4]
		# = 5byte
		"""
		writer.writeString(Code.CODE_INTEGER)
		writer.writeString(self.value)
		writer.writeLog("数値, %d"%self.value)
		writer.writeCrlf()
		
