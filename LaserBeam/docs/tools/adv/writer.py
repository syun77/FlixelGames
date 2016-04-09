#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import traceback
from stack import Stack

class Label:
	""" ラベルオブジェクト """
	def __init__(self, name, location, filename, lineno):
		self.name     = name
		self.location = location
		self.filename = filename
		self.lineno   = lineno
	def getLocation(self):
		return self.location
	def getLineno(self):
		return self.lineno
	def getName(self):
		""" ラベル名の取得 """
		return self.name
	def dump(self):
		print("<<Label.dump()>>")
		print(" -> %s location:%d lineno:%d"%(self.name, self.location, self.lineno))

class LabelLoop:
	""" ループラベル情報 """
	def __init__(self, lStart, lEnd):
		self.lStart = lStart # ループの先頭
		self.lEnd   = lEnd   # ループの終端

class Writer:
	""" スクリプト書き込みオブジェクト """
	def __init__(self, filepath, parser):
		self.filepath= filepath
		self.f       = open(filepath, "w")
		self.parser  = parser
		self.address = 1 # 1行目から開始
		self.log     = open(filepath + ".log", "w")
		self.labels      = {} # 本当のラベル（ディクショナリ）
		self.labelsProto = [] # 仮のラベル（リスト）
		self.outputs = [] # 出力文字用のリスト
		self.nowLine = "" # 現在の行の文字列
		self.loopStack = Stack()

		# ログ開始
		self.writeLogEx("## log begin ##")
	def pushLoop(self, lStart, lEnd):
		""" ループスタックを積む """
		loop = LabelLoop(lStart, lEnd)
		self.loopStack.push(loop)
	def popLoop(self):
		""" ループスタックを取り出す """
		loop = self.loopStack.pop()
		return loop
	def getLoopStartLabel(self):
		""" ループの開始ラベルを取得する """
		loop = self.loopStack.top()
		return loop.lStart
	def getLoopEndLabel(self):
		""" ループの終端ラベルを取得する """
		loop = self.loopStack.top()
		return loop.lEnd
	def writeAddress(self):
		""" 現在のアドレスを書き込む """
		self.writeString(self.address)
	def writeString(self, string):
		""" 文字列の書き込み """
		self.nowLine += "%s,"%string
	def writeLog(self, msg):
		""" ログの書き込み """
		self.log.write("%08d :%s\n"%(self.address, msg))
	def writeLogEx(self, msg):
		""" ログの書き込み２ """
		self.log.write(msg+"\n")
	def finalize(self):
		""" 終了処理 """
		# パッチ当て
		self.patchLabel()
		# ファイルに書き込む
		self.writeOutput()

		self.f.close()
		self.log.close()
	def getLocalLabel(self):
		""" ローカルラベルの名称を生成 """
		return "##%08x##"%len(self.labelsProto)
	def getRealLabel(self):
		""" 本ラベルの無名名称を生成 """
		return "@@%08x@@"%len(self.labels)
	def writeLabelProto(self):
		"""
		仮ラベルの書き込み
		@return: 作成した仮ラベルの名前
		"""
		name = self.getLocalLabel()
		self.writeLabelProtoEx(name)
		return name
	def writeLabelProtoEx(self, name, lineno=-1):
		"""
		仮ラベルを名前を指定して書き込み
		@param name: 仮ラベル名
		"""
		if lineno == -1:
			lineno = self.parser.lexer.getLineno()
		label = Label(
			name,
			self.address,
			self.parser.lexer.getFinename(),
			lineno)
		self.labelsProto.append(label)
		self.writeString(name) # 仮登録
	def fatal(self, msg):
		self.parser.fatal("%s(%d): %s"%(self.filepath, self.parser.lexer.getLineno(), msg))
	def writeLabel(self, name):
		"""
		本ラベル追加
		@param name: ラベル名
		"""
		label = Label(
			name,
			self.address,
			self.parser.lexer.getFinename(),
			self.parser.lexer.getLineno())
		if self.labels.has_key(name):
			# ラベルが重複して定義されている
			self.fatal("Duplicate label '%s'"%name)
		self.labels[name] = label
		# ラベルに実体はないので書き込まない
	def writeLabelEx(self):
		# 名前を生成する
		name = self.getRealLabel()
		# ラベル追加
		self.writeLabel(name)
		return name
	def writeCrlf(self):
		""" 改行を書き込む """
		#self.f.write("\n")

		# バッファを次の行に進める
		self.outputs.append(self.nowLine)
		self.nowLine = ""
		self.address += 1
		#traceback.print_stack()

	def writeOutput(self):
		""" 出力バッファに格納されている文字をファイルに書き出す """
		for line in self.outputs:
			if line[-1] == ",":
				# 末尾の","を取り除く
				line = line.rstrip(",")
			self.f.write(line + "\n")

	def patchLabel(self):
		""" ラベルのパッチ当て """
		self.writeLogEx("")
		self.writeLogEx("## patchLabel begin ## 'proto' <-- 'real'")
		for proto in self.labelsProto:
			if self.labels.has_key(proto.getName()):
				# 仮ラベル名を取得
				name = proto.getName()
				locProto = proto.getLocation()
				locReal  = self.labels[name].getLocation()
				# 飛び先の行の文字を取得
				row = locProto-1
				length = len(self.outputs)
				if(row >= length):
					self.writeLogEx("Error: Fail to patch label. '%s': [%08d] <-- [%08d]"%(name, locProto, locReal))
					self.writeLog("Error: Invalid jump address row = %d, max = %d"%(row+1, length+1))
					raise Exception("Error: Fail to patch label. '%s': [%08d] <-- [%08d]"%(name, locProto, locReal))
				line = self.outputs[row]
				# 仮ラベル名を正式なラベル(行数)に置き換える
				self.outputs[row] = line.replace(name, "%08d"%locReal, 1)
				#self.writeStringEx(locProto, locReal)
				self.writeLogEx("  '%s': [%08d] <-- [%08d]"%(name, locProto, locReal))
			else:
				proto.dump()
				textLine = self.parser.getLineText(proto.getLineno()-1)
				raise Exception("Not found label -> name:'%s' line:%d\n%s"%(proto.getName(), proto.getLineno(), textLine))
		self.writeLogEx("## patchLabel end ##")
