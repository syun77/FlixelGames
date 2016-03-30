#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木ブロック文クラス """
class Block(Node):
	def __init__(self, stmtList):
		self.stmtList = stmtList
	def run(self, writer):
		# 命令書き込み
		writer.writeLog("ブロック文開始")
		if not(self.stmtList is None):
			for stmt in self.stmtList:
				if not(stmt is None):
					stmt.run(writer)
		writer.writeLog("ブロック文終了")
