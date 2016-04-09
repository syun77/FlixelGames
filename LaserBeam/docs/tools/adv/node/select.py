#!/usr/bin/env python
# -*- coding: utf-8 -*-

from node import Node
from code import Code

""" 構文木選択肢クラス """
class Select(Node):
	def __init__(self, questionList, selectList, bodyList):
		self.questionList = questionList
		self.selectList   = selectList
		self.bodyList     = bodyList
	def run(self, writer):
		# 問題文書き込み
		# [opecode, 問題文の行数, [文字列]+]
		# [1,       1,            [?     ]+]
		# 2 + (?)*? byte
		writer.writeString(Code.CODE_SELECT)
		writer.writeString(len(self.questionList))
		for question in self.questionList:
			writer.writeString(question)
			writer.writeLog("問題文, %s"%(question))
		writer.writeCrlf()
		
		# 選択肢書き込み
		# [opecode, 選択肢の数, [選択肢の文字列の長さ, 文字列]+]
		# [1,       1,          [1,                  , ?     ]+]
		writer.writeString(Code.CODE_SELECT_CHOICE)
		writer.writeString(len(self.selectList))
		for select in self.selectList:
			writer.writeString(select["msg"])
			writer.writeLog("選択肢, %s"%(select))
		writer.writeCrlf()
		
		# 選択肢条件式の書き込み
		for idx, select in enumerate(self.selectList):
			node = select["cond"]
			if node is None:
				# 条件なし
				continue
			else:
				# 条件式あり
				node.run(writer)
				writer.writeString(Code.CODE_SELECT_CHOICE2)
				writer.writeString(idx)
				writer.writeCrlf()
				writer.writeLog("選択肢2, %d"%(idx))
		
		# 条件式書き込み
		# [opecode, [選択肢に該当するアドレス]+]
		# [1,       [4                       ]+]
		# 1 + 4*? byte
		writer.writeString(Code.CODE_SELECT_JUMP)
		# 仮ラベル作成
		protoLabels = []
		for i in range(len(self.bodyList)):
			name = writer.writeLabelProto()
			protoLabels.append(name)
			writer.writeLog("選択肢%dの仮ラベル '%s'"%(i, name))
		writer.writeCrlf()
		
		lEnd = None
		i = 0
		for name, body in zip(protoLabels, self.bodyList):
			writer.writeLabel(name)
			writer.writeLog("選択肢%dのラベル登録 '%s'"%(i, name))
			body.run(writer)
			writer.writeLog("選択肢%dのブロック終了 '%s'"%(i, name))
			
			writer.writeString(Code.CODE_JUMP) # ジャンプ命令
			if lEnd is None:
				lEnd = writer.writeLabelProto()  # selectブロック終了ラベルの取得
			else:
				writer.writeLabelProtoEx(lEnd)
			writer.writeLog("アドレスジャンプ, %s"%lEnd)
			writer.writeCrlf()
			i += 1
		
		# 終了ラベル作成
		writer.writeLabel(lEnd)
		writer.writeLog("選択肢終了ラベル作成, %s"%lEnd)
