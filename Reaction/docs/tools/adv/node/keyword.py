#!/usr/bin/env python
# -*- coding: utf-8 -*-

from code      import Code

""" 構文木特殊キーワードクラス """
class Keyword:
	def __init__(self, value):
		self.value = value
	def getValue(self):
		return self.value
	def run(self, writer):
		""" 特殊キーワード命令書き込み
		# [opecode, キーワード文字列]
		# [1,       4]
		# = 5byte
		"""
		writer.writeString(Code.CODE_KEYWORD)
		writer.writeString(self.value)
		writer.writeLog("キーワード, %s"%self.value)
		writer.writeCrlf()
		
