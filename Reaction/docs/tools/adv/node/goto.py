#!/usr/bin/env python
# -*- coding: utf-8 -*-

from code import Code

""" ラベルジャンプクラス """
class Goto:
	def __init__(self, name, lineno):
		self.name = name
		self.lineno = lineno
	def run(self, writer):
		# 命令書き込み
		# [opecode, 飛び先のアドレス]
		# [1      , 4               ]
		# = 5byte

		# 命令コードを書き込む
		writer.writeString(Code.CODE_JUMP)
		# ラベルを作成
		writer.writeLabelProtoEx(self.name, self.lineno)
		# デバッグ用にラベル名を残しておく
		writer.writeString(self.name)
		writer.writeLog("アドレスジャンプ, %s"%self.name)
		writer.writeCrlf()
