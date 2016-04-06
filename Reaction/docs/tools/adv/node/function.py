#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木関数クラス """
class Function(Node):
	def __init__(self, name, body):
		self.name = name
		self.body = body
	def run(self, writer):
		# 命令書き込み TODO:ラベルからファンクションにする
		writer.writeLabel(self.name)
		writer.writeLog("ファンクション作成 '%s'"%self.name)
		writer.writeString(Code.CODE_FUNC_START)
		writer.writeString(self.name)
		writer.writeCrlf()
		
		self.body.run(writer)

		# [opecode]
		# [1      ]
		# = 1byte
		writer.writeString(Code.CODE_FUNC_END)
		writer.writeString(self.name)
		writer.writeLog("ファンクション終了 '%s'"%self.name)
		writer.writeCrlf()
		