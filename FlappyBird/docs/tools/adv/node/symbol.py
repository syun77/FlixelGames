#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" 構文木変数クラス """

from node import Node
from code import Code

class Symbol(Node):
	def __init__(self, symbol):
		try:
			self.number = int(symbol) # 変数の番号
		except:
			raise Exception("Error: Illigal symbol")
	def getNumber(self):
		return self.number
	def run(self, writer):
		""" 変数命令書き込み（参照した場合のみ。変数代入時はAssignクラス）
		# [opecode, 変数の番号値]
		# [1,       4           ]
		# = 5byte
		"""
		writer.writeString(Code.CODE_SYMBOL)
		writer.writeString(self.number)
		writer.writeLog("変数, %d"%self.number)
		writer.writeCrlf()
