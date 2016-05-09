#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# メッセージデータ
python xls2csv.py message.xlsx ../assets/data/csv

#read Wait

# ターミナルを閉じる
#killall Terminal
