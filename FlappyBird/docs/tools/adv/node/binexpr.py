#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node      import Node
from code      import Code
from tokentype import TokenType

""" 構文木二項演算クラス """
class BinExpr(Node):
	def __init__(self, op, nodeL, nodeR):
		self.op = op
		self.nodeL = nodeL
		self.nodeR = nodeR
	def run(self, writer):
		self.nodeL.run(writer)
		self.nodeR.run(writer)
		# 命令書き込み
		# [opecode]
		# [1]
		# = 1byte
		if self.op == '+':
			opecode = Code.CODE_ADD
		elif self.op == '-':
			opecode = Code.CODE_SUB
		elif self.op == '*':
			opecode = Code.CODE_MUL
		elif self.op == '/':
			opecode = Code.CODE_DIV
		elif self.op == TokenType.AND:
			opecode = Code.CODE_AND
		elif self.op == TokenType.OR:
			opecode = Code.CODE_OR
		elif self.op == TokenType.EQ:
			opecode = Code.CODE_EQ
		elif self.op == TokenType.NE:
			opecode = Code.CODE_NE
		elif self.op == '<':
			opecode = Code.CODE_LE
		elif self.op == TokenType.LESS:
			opecode = Code.CODE_LESS
		elif self.op == '>':
			opecode = Code.CODE_GE
		elif self.op == TokenType.GREATER:
			opecode = Code.CODE_GREATER
		writer.writeString(opecode)
		writer.writeLog("演算子'%s'"%self.op)
		writer.writeCrlf()
		
