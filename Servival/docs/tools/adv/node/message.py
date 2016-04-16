#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木メッセージクラス """
class Message(Node):
	def __init__(self, message):
		# TODO: フォーマットチェック
		suffix = message[len(message)-1]
		if suffix == "/":
			# 改ページ記号がある
			self.pagefeed = 1
			message = message[:len(message)-1]
		elif suffix == "@":
			# クリック待ちがある
			self.pagefeed = 2
			message = message[:len(message)-1]
		else:
			self.pagefeed = False
		self.message = message
	def run(self, writer):
		""" メッセージ命令書き込み
		# [opecode, 改ページフラグ, 文字列]
		# [1,       1,           ?]
		# = 2+?byte
		"""
		writer.writeString(Code.CODE_MESSAGE)
		if self.pagefeed == 1:
			ff = Code.MSG_FF
		elif self.pagefeed == 2:
			ff = Code.MSG_CLICK
		else:
			ff = Code.MSG_NEXT
		writer.writeString(ff)
		writer.writeString(self.message)
		writer.writeLog("メッセージ, %d, %s"%(self.pagefeed, self.message))
		writer.writeCrlf()
