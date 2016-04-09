#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木符号反転クラス """
class Minus(Node):
	def __init__(self, nodeR):
		self.nodeR = nodeR
	def run(self, writer):
		# 命令書き込み
		self.nodeR.run(writer)
		# 反転
		# [opecode]
		# [1      ]
		# = 1byte
		writer.writeString(Code.CODE_MINUS)
		writer.writeLog("符号反転")
		writer.writeCrlf()
		
		