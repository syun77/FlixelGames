#!/usr/bin/env python
# -*- coding: utf-8 -*-

class Code:
	""" 命令コードオブジェクト """
	CODE_MESSAGE = "MSG" # メッセージ
	CODE_INTEGER = "INT" # 数値
	CODE_COLOR   = "COL" # 色（#ffffff）
	CODE_VAR     = "VAR" # 変数
	CODE_KEYWORD = "KEY" # 特殊キーワード
	# ■演算子
	CODE_ASSIGN  = "SET" # 代入演算子'='
	CODE_ADD     = "ADD" # 加算演算子'+'
	CODE_SUB     = "SUB" # 減算演算子'-'
	CODE_MUL     = "MUL" # 乗算演算子'*'
	CODE_DIV     = "DIV" # 除算演算子'/'
	CODE_MINUS   = "NEG" # 符号反転'-'
	CODE_BOOL    = "BOOL" # 真偽
	CODE_NOT     = "NOT" # 否定
	CODE_EQ      = "EQ" # '=='
	CODE_NE      = "NE" # '!='
	CODE_LE      = "LE" # '<'
	CODE_LESS    = "LESS" # '<='
	CODE_GE      = "GE" # '>'
	CODE_GREATER = "GREATER" # '>='
	CODE_AND     = "AND" # '&&'
	CODE_OR      = "OR" # '||'
	# ■制御構造
	CODE_IF      = "IF" # if文
	CODE_ELIF    = "ELIF" # elif文
	CODE_WHILE   = "WHILE" # while文
	CODE_JUMP    = "GOTO" # アドレスジャンプ
	CODE_END     = "END" # スクリプトの終端
	# ■選択肢
	CODE_SELECT         = "SEL" # 選択肢
	CODE_SELECT_CHOICE  = "SEL_ANS" # 選択肢の文
	CODE_SELECT_CHOICE2 = "SEL_ANS2" # 選択肢の文の条件式
	CODE_SELECT_JUMP    = "SEL_GOTO" # 選択肢によるジャンプ
	# ■制御構造
	CODE_CALL      = "CALL"     # ファンクション呼び出し
	CODE_LABEL     = "LABEL"    # ラベル定義
	CODE_RETURN    = "RETURN"   # ファンクションを抜ける
	CODE_FUNC_START = "FUNC_START" # ファンクションの開始
	CODE_FUNC_END   = "FUNC_END"   # ファンクションの終端
	# ■組み込み関数
	CODE_DRAW_BG = "DRB"  # 背景描画命令
	CODE_ERASE_BG = "ERB" # 背景消去命令


	# メッセージの改ページ
	MSG_NEXT  = 0x00 # なし
	MSG_FF    = 0x01 # 改ページ（キー入力待ち）
	MSG_CLICK = 0x02 # クリック待ち（改ページしないキー入力待ち）
	# 代入の種類
	ASSIGN_EQ  = 0x00 # そのまま
	ASSIGN_ADD = 0x01 # 加算
	ASSIGN_SUB = 0x02 # 減算
	ASSIGN_MUL = 0x03 # 乗算
	ASSIGN_DIV = 0x04 # 除算
	# 真偽の種類
	BOOL_FALSE = 0x00 # 偽
	BOOL_TRUE  = 0x01 # 真

	# 描画タイプ
	DRAW_TYPE_COLOR = 0x00 # RGBで描画
	DRAW_TYPE_ID    = 0x01 # 画像を描画

	# エフェクトID
	EF_NORMAL    = 0x00 # 瞬間表示
	EF_SCROLL_L  = 0x01 # 左スクロール
	EF_SCROLL_R  = 0x02 # 右スクロール
	EF_SCROLL_U  = 0x03 # 上スクロール
	EF_SCROLL_D  = 0x04 # 下スクロール
	EF_SHUTTER_L = 0x05 # 左シャッター
	EF_SHUTTER_R = 0x06 # 右シャッター
	EF_SHUTTER_U = 0x07 # 上シャッター
	EF_SHUTTER_D = 0x08 # 下シャッター
	EF_ALPHA     = 0x09 # アルファブレンド（半透明）
	EF_GRAY      = 0x0A # グレースケール（白黒）
	EF_SEPIA     = 0x0B # セピア
	EF_NEGA      = 0x0C # ネガポジ（反転）

