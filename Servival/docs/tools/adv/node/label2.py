#!/usr/bin/env python
# -*- coding: utf-8 -*-

from code      import Code

""" ラベル定義クラス """
class Label2:
	def __init__(self, name):
		self.name = name
	def run(self, writer):
		# 命令書き込み
		writer.writeLabel(self.name)
		writer.writeLog("ラベル作成 '%s'"%self.name)

		# [opecode, name]
		# [1      , strlen]
		# = 1byte + strlen
		writer.writeString(Code.CODE_LABEL)
		writer.writeString(self.name)
		writer.writeCrlf()
		