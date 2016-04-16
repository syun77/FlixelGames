#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木continue文クラス """
class Continue(Node):
	def __init__(self):
		pass
	def run(self, writer):
		# continue文 (ラベルジャンプ)
		# [opecode, 飛び先のアドレス]
		# [1      , 4               ]
		# = 5byte

		# ループ開始ラベル名を取得
		name = writer.getLoopStartLabel()
		# 命令コードを書き込む
		writer.writeString(Code.CODE_JUMP)
		# ラベルを作成
		writer.writeLabelProtoEx(name)
		# デバッグ用にラベル名を残しておく
		writer.writeString("continue:"+name)
		writer.writeLog("continue文, %s"%name)
		writer.writeCrlf()
