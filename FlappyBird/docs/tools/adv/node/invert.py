#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木否定クラス """
class Invert(Node):
	def __init__(self, nodeR):
		self.nodeR = nodeR
	def run(self, writer):
		# 命令書き込み
		self.nodeR.run(writer)
		# 否定
		# [opecode]
		# [1      ]
		# = 1byte
		writer.writeString(Code.CODE_NOT)
		writer.writeLog("否定")
		writer.writeCrlf()
		
		