#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木return文クラス """
class Return(Node):
	def __init__(self, cond):
		self.cond = cond
	def run(self, writer):
		if not(self.cond is None):
			# 条件式書き込み
			self.cond.run(writer)
		
		# return文
		# [opecode]
		# [1      ]
		# = 1byte
		writer.writeString(Code.CODE_RETURN)
		writer.writeLog("return文")
		writer.writeCrlf()
