#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node      import Node
from tokentype import TokenType
from code      import Code
from binascii  import *

""" 構文木代入演算クラス """
class Assign(Node):
	def __init__(self, op, var, nodeR):
		self.op     = op    # 演算の種類
		self.var    = var   # 代入される変数
		self.nodeR  = nodeR # 右辺の式
	def run(self, writer):
		self.nodeR.run(writer)
		# 代入命令書き込み
		# [opecode, 代入の種類, 変数番号]
		# [1,       1,          4       ]
		# = 5byte
		writer.writeString(Code.CODE_ASSIGN)
		if self.op == '=':
			ttype = Code.ASSIGN_EQ
		elif self.op == TokenType.IADD:
			ttype = Code.ASSIGN_ADD
		elif self.op == TokenType.ISUB:
			ttype = Code.ASSIGN_SUB
		elif self.op == TokenType.IMUL:
			ttype = Code.ASSIGN_MUL
		elif self.op == TokenType.IDIV:
			ttype = Code.ASSIGN_DIV
		writer.writeString(ttype)
		writer.writeString(self.var.getNumber())
		writer.writeLog("代入, %d, $%d"%(ttype, self.var.getNumber()))
		writer.writeCrlf()
