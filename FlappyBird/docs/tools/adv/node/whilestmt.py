#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木while文クラス """
class While(Node):
	def __init__(self, cond, bodyThen, bodyElse):
		self.cond = cond
		self.bodyThen     = bodyThen
		self.bodyElse     = bodyElse
	def run(self, writer):
		# while文開始
		# [opecode, ラベル]
		# [1      ,  4]
		writer.writeString(Code.CODE_WHILE)
		# while開始ラベルの書き込み・取得
		lWhile = writer.writeLabelEx()
		# while-else終了ラベルの作成
		lEnd = writer.writeLabelProto()
		writer.writeCrlf()
		writer.writeLog("while文開始, %s"%lWhile)

		# ループラベルをpush
		writer.pushLoop(lWhile, lEnd)

		# 条件式書き込み
		self.cond.run(writer)

		# 条件式判定
		# [opecode, 初回の偽の場合の飛び先
		# [1      , 4                 ]
		# = 5byte
		writer.writeString(Code.CODE_IF)
		lElse = writer.writeLabelProto() # elseラベルの取得
		#writer.writeLabel(lEnd)
		writer.writeLog("if文, %s"%lElse)
		writer.writeCrlf()

		# then
		self.bodyThen.run(writer)

		# while-end
		# [opecode, 飛び先]
		# [1      , 4     ]
		# = 5byte
		writer.writeString(Code.CODE_JUMP) # ジャンプ命令
		writer.writeLabelProtoEx(lWhile) # whileに戻る
		writer.writeLog("アドレスジャンプ, %s"%lWhile)
		writer.writeCrlf()

		# else文
		# elseラベル作成
		writer.writeLabel(lElse)
		writer.writeLog("elseラベル作成, %s"%lElse)

		# else
		if not(self.bodyElse is None):
			self.bodyElse.run(writer)

		#while-elseブロック終了ラベル作成
		writer.writeLabel(lEnd)
		writer.writeLog("while-elseブロック終了ラベル作成, %s"%lEnd)

		# ループラベルを取り出す
		writer.popLoop()
