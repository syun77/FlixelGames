#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 構文木色クラス """
from node import Node
from code import Code
from binascii import *

class Color(Node):
	def __init__(self, value):
		if value[0] != '#':
			raise Exception("Error: Illigal parameter. ->%s"%value)
		self.value = value
		self.binColor = a2b_hex(value[1:])
		if len(self.binColor) != 3:
			raise Exception("Error: Illigal color parameter. ->%s"%value)
	def getValue(self):
		return self.value
	def getBinaryString(self):
		return self.binColor
	def run(self, writer):
		""" 数値命令書き込み
		# [opecode, 色番号]
		# [1,       4]
		# = 5byte
		"""
		writer.writeString(Code.CODE_COLOR)
		writer.writeString(self.nColor)
		writer.writeLog("色, %s"%self.nColor)
		writer.writeCrlf()
		
