#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

class Elif:
	""" Elifクラス """
	def __init__(self, cond, body):
		self.cond = cond
		self.body = body
	def getCond(self):
		return self.cond
	def getBody(self):
		return self.body

""" 構文木if文クラス """
class If(Node):
	def __init__(self, cond, bodyThen, bodyElifList, bodyElse):
		self.cond = cond
		self.bodyThen     = bodyThen
		self.bodyElifList = bodyElifList
		self.bodyElse     = bodyElse
	def run(self, writer):
		# 条件式書き込み
		self.cond.run(writer)
		
		# if文
		# [opecode, 偽の場合の飛び先]
		# [1      , 4               ]
		# = 5byte
		writer.writeString(Code.CODE_IF)
		lElse = writer.writeLabelProto() # elseラベルの取得
		writer.writeLog("if文, %s"%lElse)
		writer.writeCrlf()
		
		# then
		self.bodyThen.run(writer)

		# if-end
		# [opecode, 飛び先]
		# [1      , 4     ]
		# = 5byte
		writer.writeString(Code.CODE_JUMP) # ジャンプ命令
		lEnd = writer.writeLabelProto()  # elseブロック終了ラベルの取得
		writer.writeLog("アドレスジャンプ, %s"%lEnd)
		writer.writeCrlf()
		
		# elif文
		for bodyElif in self.bodyElifList:
			# elifラベル作成
			writer.writeLabel(lElse)
			writer.writeLog("elifラベル作成, %s"%lElse)
			
			# 命令書き込み
			bodyElif.getCond().run(writer)
			
			# elif文
			# [opecode, 偽の場合の飛び先]
			# [1      , 4               ]
			# = 5byte
			writer.writeString(Code.CODE_ELIF)
			lElse = writer.writeLabelProto()
			writer.writeLog("elif文, %s"%lElse)
			writer.writeCrlf()
		
			# then
			bodyElif.getBody().run(writer)
		
			# elif-end
			writer.writeString(Code.CODE_JUMP) # ジャンプ命令
			writer.writeLabelProtoEx(lEnd)   # elseブロック終了ラベルの書き込み
			writer.writeLog("アドレスジャンプ, %s"%lEnd)
			writer.writeCrlf()
		
		# else文
		# elseラベル作成
		writer.writeLabel(lElse)
		writer.writeLog("elseラベル作成, %s"%lElse)
		
		# else
		if not(self.bodyElse is None):
			self.bodyElse.run(writer)
		
		# if-elseブロック終了ラベル作成
		writer.writeLabel(lEnd)
		writer.writeLog("if-elseブロック終了ラベル作成, %s"%lEnd)
		