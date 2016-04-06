#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木真偽クラス """
class Bool(Node):
	def __init__(self, ttype):
		self.ttype = ttype
	def run(self, writer):
		# 命令書き込み
		# [opecode, 真or偽]
		# [1      , 1     ]
		# = 1byte
		writer.writeString(Code.CODE_BOOL)
		if self.ttype:
			bool = Code.BOOL_TRUE
		else:
			bool = Code.BOOL_FALSE
		writer.writeString(bool)
		writer.writeLog("真偽, %d"%self.ttype)
		writer.writeCrlf()
				