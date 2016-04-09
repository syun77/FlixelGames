#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import glob

def usage():
	print "Usage: conv_ai.py [gmadv.py] [define_functions.h] [define_consts.txt] [input_dir] [output_dir]"

def main(tool, fFuncDef, fDefines, inputDir, outDir):
	# *.txtを取得
	txtList = glob.glob("%s*.txt"%inputDir)

	for txt in txtList:
		fInput = txt
		fOut   = outDir + txt.replace(inputDir, "").replace(".txt", ".csv")

		cmd = "python %s %s %s %s %s"%(
			tool, fFuncDef, fDefines, fInput, fOut)
		print cmd
		os.system(cmd)

if __name__ == '__main__':
	args = sys.argv
	argc = len(sys.argv)
	if argc < 6:
		# 引数が足りない
		print args
		print "Error: Not enough parameter. given=%d require=%d"%(argc, 6)
		usage()
		quit()

	# ツール
	tool = args[1]
	# 関数定義
	fFuncDef = args[2]
	# 定数定義
	fDefines = args[3]
	# 入力フォルダ
	inputDir = args[4]
	# 出力フォルダ
	outDir = args[5]

	main(tool, fFuncDef, fDefines, inputDir, outDir)
