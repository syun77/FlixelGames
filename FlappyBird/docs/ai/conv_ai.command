#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# ツール
tool=../tools/adv/gmadv.py
# 関数定義
funcDef=define_functions.h
# 定数定義
defines=../dummy_header.txt
# 入力フォルダ
inputDir=./
# 出力フォルダ
outDir=../../assets/data/ai/

# コンバート実行
python conv_ai.py $tool $funcDef $defines $inputDir $outDir

#read Wait

# ターミナルを閉じる
#killall Terminal
