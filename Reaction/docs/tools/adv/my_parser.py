#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 2014/01/18

@author: syun
'''
import re
import shlex
import string
import yaml

from lexer     import *
from writer    import Writer
from tokentype import TokenType
from code      import Code

from node.message  import Message
from node.integer  import Integer
from node.color    import Color
from node.var      import Var
from node.binexpr  import BinExpr
from node.assign   import Assign
from node.minus    import Minus
from node.bool     import Bool
from node.invert   import Invert
from node.ifstmt   import If, Elif
from node.whilestmt import While
from node.block    import Block
from node.select   import Select
from node.goto     import Goto
from node.function import Function
from node.define   import Define
from node.keyword  import Keyword
from node.label2   import Label2
from node.call     import Call
from node.retstmt  import Return
from node.continuestmt import Continue
from node.breakstmt import Break

from node.primitive.primitive import parsePrivitiveSettings, Primitive

class MyParser:
    """ 構文解析クラス """
    def __init__(self, lexer, funcfile, defines):
        self.nLevel = 0 # ノードの深さ
        self.lexer = lexer
        # グローバルシンボルをロードする
        self.globals = parsePrivitiveSettings(funcfile)
        # 定数テーブル
        self.defines = {
            "EF_NORMAL"    : Code.EF_NORMAL,
            "EF_SCROLL_L"  : Code.EF_SCROLL_L,
            "EF_SCROLL_R"  : Code.EF_SCROLL_R,
            "EF_SCROLL_U"  : Code.EF_SCROLL_U,
            "EF_SCROLL_D"  : Code.EF_SCROLL_D,
            "EF_SHUTTER_L" : Code.EF_SHUTTER_L,
            "EF_SHUTTER_R" : Code.EF_SHUTTER_R,
            "EF_SHUTTER_U" : Code.EF_SHUTTER_U,
            "EF_SHUTTER_D" : Code.EF_SHUTTER_D,
            "EF_ALPHA"     : Code.EF_ALPHA,
            "EF_GRAY"      : Code.EF_GRAY,
            "EF_SEPIA"     : Code.EF_SEPIA,
            "EF_NEGA"      : Code.EF_NEGA
        }
        for fDefine in defines.split(","):
            f = open(fDefine)
            data = yaml.load(f)["data"]
            self.defines.update(data)
            f.close

        # 特殊キーワード
        self.keywords = {
            "stat": "STAT",
        }
    def hasGlobals(self, name):
        return self.globals.has_key(name)
    def getGlobals(self, name):
        """ シンボルの取得 """
        glob = self.globals[name]
        return glob.getInstance()
    def hasDefines(self, name):
        return self.defines.has_key(name)
    def getDefines(self, name):
        """ 定数の取得 """
        define = self.defines[name]
        return define
    def hasKeyword(self, name):
        return self.keywords.has_key(name)
    def getKeywords(self, name):
        """ キーワードの取得 """
        key = self.keywords[name]
        return key
    def getTokenType(self):
        return self.lexer.ttype
    def lookAhead(self):
        """ 先読みする """
        if self.lexer.advance():
            return self.lexer.ttype
        else:
            return None
    def unread(self, token):
        """ 字句を１文字戻す """
        if self.lexer.ttype == TokenType.GOTO:
            self.lexer.unread(self.lexer.token) # ラベル
            self.lexer.unread("goto")
        elif self.lexer.ttype == TokenType.CALL:
            self.lexer.unread(self.lexer.token) # ラベル
            self.lexer.unread("call")
        elif self.lexer.ttype == TokenType.LABEL:
            self.lexer.unread(":")
            self.lexer.unread(self.lexer.token) # ラベル
        else:
            self.lexer.unread(token)
    def warning(self, msg):
        """ 警告書き込み """
        message = "Warning :%s"%msg
        self.writeLog(message)
    def getLineText(self, lineno=-1):
        """ 指定の行のテキストを取得する """
        return self.lexer.getLineText(lineno)
    def fatal(self, msg):
        """ エラー書き込む """
        self.lexer.fatal(msg)
    def skipCrlf(self):
        """ 改行をスキップ """
        ttype = self.getTokenType()
        while ttype == TokenType.CRLF:
            if ttype is None:
                break
            ttype = self.lookAhead()
        return ttype
    def parse(self, filepath):
        """ 解析 """
        writer = Writer(filepath, self)
        self.writer = writer
        while not(self.lookAhead() is None):
            node = self.parseProgram()
            if not(node is None):
                node.run(writer)
        # スクリプトの終端を書き込む
        writer.writeString(Code.CODE_END)
        writer.writeCrlf()

        # 終了処理
        writer.finalize()
        print "convert done."
    def parseProgram(self):
        """ プログラムの解析
        # プログラム ← 文 '¥n'
        """
        node = self.parseStatement()
        if not(node is None):
            if self.getTokenType() == TokenType.CRLF:
                pass
        return node
    def parseStatement(self):
        """ 文の解析
        # 文 ← if文
        #    ｜ while文
        #    ｜ select文
        #    ｜ functionブロック
        #    ｜ 式
        #    ｜ ブロック文
        #    ｜ return文
        #    ｜ continue文
        #    ｜ break文
        """
        self.nLevel += 1 # ノードを深くする
        node = None
        ttype = self.getTokenType()
        if ttype == TokenType.IF:
            node = self.parseStatementIf()
        elif ttype == TokenType.WHILE:
            node = self.parseStatementWhile()
        elif ttype == TokenType.SELECT:
            node = self.parseStatementSelect()
        elif ttype == TokenType.FUNCTION:
            node = self.parseStatementFunction()
        elif ttype == '{':
            node = self.parseStatementBlock()
        elif ttype == TokenType.RETURN:
            node = self.parseStatementReturn()
        elif ttype == TokenType.CONTINUE:
            node = self.parseStatementContinue()
        elif ttype == TokenType.BREAK:
            node = self.parseStatementBreak()
        else:
            node = self.parseExpression()
        self.nLevel -= 1 # ノードレベルを下げる
        return node
    def parseStatementIf(self):
        """ if文の解析
        # if文 ← 'if' '(' 式 ')' 文 ['elif' '(' 式 ')' 文]* ['else' 文]?
        """
        ttype = self.lookAhead()
        if ttype != '(':
            self.fatal("Illigal grammar 'if'statement need '(' ttype=%r"%ttype)
        self.lookAhead() # skip '('
        cond = self.parseExpression()
        if self.getTokenType() != ')':
            self.fatal("Illigal grammar 'if'statement need ')' ttype=%r"%ttype)
        self.lookAhead() # skip ')'
        ttype = self.skipCrlf()
        bodyThen = self.parseStatement()
        ttype = self.skipCrlf()

        # elifリスト
        bodyElifList = []
        ttype = self.getTokenType()
        while ttype == TokenType.ELIF:
            ttype = self.lookAhead()
            if ttype != '(':
                self.fatal("Illigal grammar 'elif'statement need '(' ttype=%r"%ttype)
            self.lookAhead() # skip '('
            condElif = self.parseExpression()
            if self.getTokenType() != ')':
                self.fatal("Illigal grammar 'elif'statement need ')' ttype=%r"%ttype)
            self.lookAhead() # skip ')'
            ttype = self.skipCrlf()
            bodyElif = self.parseStatement()
            bodyElifList.append(Elif(condElif, bodyElif))
            #ttype = self.getTokenType()
            ttype = self.skipCrlf()
            if ttype is None:
                break
        ttype = self.skipCrlf()

        # else
        bodyElse = None
        if ttype == TokenType.ELSE:
            self.lookAhead() # skip 'else'
            ttype = self.skipCrlf()
            bodyElse = self.parseStatement()

        self.unread(self.lexer.token)
        if self.nLevel == 1: # ルートノードであればダミーを入れておく
            self.unread('¥n')
        self.lookAhead()
        return If(cond, bodyThen, bodyElifList, bodyElse)
    def parseStatementWhile(self):
        """ while文の解析
        # while文 ← 'while' '(' 式 ')' 文
        """
        ttype = self.lookAhead() # whileを読み飛ばす
        if ttype != '(':
            self.fatal("Illigal grammar 'while'statement need '(' ttype=%r"%ttype)
        self.lookAhead() # skip '('
        cond = self.parseExpression()
        if self.getTokenType() != ')':
            self.fatal("Illigal grammar 'while'statement need ')' ttype=%r"%ttype)
        self.lookAhead() # skip ')'
        ttype = self.skipCrlf()
        bodyThen = self.parseStatement()
        ttype = self.skipCrlf()

        # else
        bodyElse = None
        if ttype == TokenType.ELSE:
            self.lookAhead() # skip 'else'
            ttype = self.skipCrlf()
            bodyElse = self.parseStatement()

        # 後処理
        self.unread(self.lexer.token)
        if self.nLevel == 1: # ルートノードであればダミーを入れておく
            self.unread('¥n')
        self.lookAhead()
        return While(cond, bodyThen, bodyElse)

    def parseStatementSelect(self):
        """ select文の解析
        # select文 ← 'select' '(' "問題文" ')' ['{' "選択肢" '}']+
        """
        ttype = self.lookAhead()
        if ttype != '(':
            # select命令の次は'('でないとダメ
            self.fatal("Illigal grammar 'select'statement need '('")

        # 選択肢の解析
        questionList = self.parseSelectQuestion()
        selectList = [] # 選択肢
        bodyList   = [] # 選択ブロック
        ttype = self.skipCrlf()
        if ttype != '{':
            self.fatal("Illigal grammar 'select'statement need '{'")
        while ttype == '{':
            # 選択肢の解析
            self.lookAhead()
            ttype = self.skipCrlf()
            sel = {} # 選択肢情報 ("msg"=メッセージ "cond"=条件式)
            if ttype == TokenType.QUOTES:
                # 条件なしの選択肢
                sel["cond"] = None # 条件なし
                sel["msg"]  = self.lexer.token.strip('"')
                selectList.append(sel)
                body = self.parseStatementBlock()
                bodyList.append(body)
                #self.lookAhead()
                ttype = self.skipCrlf()
            else:
                # 条件式ありの選択肢
                cond = self.parseExpression()
                ttype = self.lookAhead()
                if ttype == TokenType.QUOTES:
                    sel["cond"] = cond
                    sel["msg"]  = self.lexer.token.strip('"')

                    selectList.append(sel)
                    body = self.parseStatementBlock()
                    bodyList.append(body)
                    #self.lookAhead()
                    ttype = self.skipCrlf()
                else:
                    # 条件式の後ろがメッセージでない
                    self.fatal("Illigal grammar 'select'statement not found 'chioses'")

        self.unread(self.lexer.token)
        if self.nLevel == 1: # ルートノードであればダミーを入れておく
            self.unread('¥n')
        self.lookAhead()
        return Select(questionList, selectList, bodyList)

    def parseSelectQuestion(self):
        """ select問題文の解析
        # select問題文 ← '(' (文字列)? ['¥n' (文字列)]* ')'
        """
        ttype = self.getTokenType()
        if ttype != '(':
            self.fatal("Illigal grammar parameter need '('")
        ttype = self.lookAhead() # skip '('
        ttype = self.skipCrlf()

        strList = []
        while ttype != ')':
            if ttype is None:
                break
            if ttype == TokenType.QUOTES:
                # メッセージ
                strList.append(self.lexer.token.strip('"'))
                self.lookAhead()
                ttype = self.skipCrlf()
            else:
                # メッセージでない
                self.fatal("Illigal grammar parameter need ""message"" ")

        self.lookAhead()
        return strList

    def parseStatementFunction(self):
        """ defブロックの解析
        # defブロック ← 'def' ファンクション名 ブロック文
        """
        name = self.lexer.token
        # defキーワードを読み捨てる
        self.lookAhead()
        ttype = self.skipCrlf()
        if ttype != '{':
            self.fatal("Illigal grammar 'define funtion' need '{'")
        body = self.parseStatementBlock()
        return Function(name, body)
    def parseStatementBlock(self):
        """ ブロック文の解析
        # ブロック文 ← '{' [文 '¥n']* '}'
        """
        stmtList = None
        self.lookAhead() # skip '{'
        while self.isNextStatementBlock():
            # ブロック内の文を解析する
            stmt = self.parseStatement()
            if self.lexer.lexReader.isEof():
                self.fatal("Illigal grammar file EOF before 'CRLF' or '}' ")

            if self.getTokenType() == TokenType.CRLF:
                self.skipCrlf()
            elif self.getTokenType() == '}':
                pass
            else:
                # ブロック文には複数の文が含まれるのでエラーとしないように修正
                pass
            if stmtList is None:
                stmtList = []
            stmtList.append(stmt)
        self.lookAhead() # skip '}'
        return Block(stmtList)
    def isNextStatementBlock(self):
        """ 次もブロック文かどうか """
        ttype = self.getTokenType()
        if ttype == '}':
            return False
        if ttype is None:
            return False
        return True
    def parseStatementReturn(self):
        """ return文の解析
        # return文 ← 'return' '(' 式 ')'
        """
        # returnキーワードを読み捨てる
        ttype = self.lookAhead()
        cond = self.parseExpression()
        return Return(cond)
    def parseStatementContinue(self):
        """ continue文の解析
        # continue文 ← 'continue'
        """
        # continueキーワードを読み捨てる
        ttype = self.lookAhead()
        return Continue()
    def parseStatementBreak(self):
        """ break文の解析
        # break文 ← 'break'
        """
        # breakキーワードを読み捨てる
        ttype = self.lookAhead()
        return Break()
#    def isExpression(self):
#        """ 式かどうか """
#        ttype = self.getTokenType()
#        return (ttype == TokenType.EQ
#            or ttype == TokenType.NE
#            or ttype == '<'
#            or ttype == TokenType.LESS
#            or ttype == '>'
#            or ttype == TokenType.GREATER)
    def isExpression2(self):
        ttype = self.getTokenType()
        return ttype in [
            TokenType.AND,
            TokenType.OR,
        ]
    def parseExpression(self):
        # 式 ← 単純式 [('==' | '!=' | '<' | '<=' | '>' | '>=') 単純式]*
        """
        # 式 ← 単純式 [('&&' | '||') 単純式]*
        """
        node = self.parseSimpleExpression()
        #if self.isExpression():
        if self.isExpression2():
            node = self.createExpression(node)
        return node
    def createExpression(self, nodeL):
        """ 式の構文木の生成 """
        result = None
        #while self.isExpression():
        while self.isExpression2():
            op = self.getTokenType()
            self.lookAhead()
            nodeR = self.parseSimpleExpression()
            if result is None:
                result = BinExpr(op, nodeL, nodeR)
            else:
                result = BinExpr(op, result, nodeR)
        return result
#    def isSimpleExpression(self):
#        """ 単純式かどうか """
#        ttype = self.getTokenType()
#        return ttype == '+' or ttype == '-' or ttype == TokenType.OR
    def isSimpleExpression2(self):
        ttype = self.getTokenType()
        return ttype in [
            TokenType.EQ,
            TokenType.NE,
            '<',
            TokenType.LESS,
            '>',
            TokenType.GREATER,
        ]
    def parseSimpleExpression(self):
        # 単純式 ← 項 [('+' | '-' | '||') 項]*
        """
        # 単純式 ← 項 [('==' | '!=' | '<' | '<=' | '>' | '>=') 項]*
        """
        node = self.parseTerm()
        #if self.isSimpleExpression():
        if self.isSimpleExpression2():
            node = self.createSimpleExpression(node)
        return node
    def createSimpleExpression(self, nodeL):
        """ 単純式の構文木の生成 """
        result = None
        #while self.isSimpleExpression():
        while self.isSimpleExpression2():
            op = self.getTokenType()
            self.lookAhead()
            nodeR = self.parseTerm()
            if result is None:
                result = BinExpr(op, nodeL, nodeR)
            else:
                result = BinExpr(op, result, nodeR)
        return result
 #   def isTerm(self):
 #       """ 項かどうか """
 #       ttype = self.getTokenType()
 #       return ttype == '*' or ttype == '/' or ttype == TokenType.AND
    def isTerm2(self):
        ttype = self.getTokenType()
        return ttype in [
            '+',
            '-',
            '*',
            '/',
        ]
    def parseTerm(self):
        # 項 ← 因子 [('*' | '/' | '&&') 因子]*
        """ 項
        # 項 ← 因子 [('+' | '-' | '*' | '/') 因子]*
        """
        node = self.parseFactor()
        if self.isTerm2():
            node = self.createTerm(node)
        return node
    def createTerm(self, nodeL):
        """ 項の構文木の生成 """
        result = None
        while self.isTerm2():
            op = self.getTokenType()
            self.lookAhead()
            nodeR = self.parseFactor()
            if result is None:
                result = BinExpr(op, nodeL, nodeR)
            else:
                result = BinExpr(op, result, nodeR)
        return result
    def parseFactor(self):
        """ 因子の解析
        # 因子 ← 数値
        #      ｜ 色（#ffffff）
        #      ｜ 真
        #      ｜ 偽
        #      ｜ '-' 因子
        #      ｜ '!' 因子
        #      ｜ '(' 式 ')'
        #      ｜ 変数
        #      ｜ 変数 '=' 式
        #      ｜ メッセージ表示
        #      ｜ goto ラベル
        #      ｜ 関数呼び出し
        #      ｜ ラベル:
        """
        ttype = self.getTokenType()
        if ttype == TokenType.INT:
            node = Integer(self.lexer.token)
            self.lookAhead() # skip INT
        elif ttype == TokenType.COLOR:
            node = Color(self.lexer.token)
            self.lookAhead() # skip COLOR
        elif ttype == TokenType.TRUE:
            node = Bool(True)
            self.lookAhead() # skip 'true'
        elif ttype == TokenType.FALSE:
            node = Bool(False)
            self.lookAhead() # skip 'false'
        elif ttype == '!':
            self.lookAhead() # skip '!'
            node = Invert(self.parseFactor())
        elif ttype == '-':
            self.lookAhead() # skip '-'
            node = Minus(self.parseFactor())
        elif ttype == '(':
            self.lookAhead() # skip '('
            node = self.parseExpression()
            if self.getTokenType() != ')':
                self.fatal("Illigal grammar not pair ')'")
            self.lookAhead() # skip ')'
        elif ttype == TokenType.VAR:
            sym = self.parseVar()
            ttype = self.lookAhead()
            if ttype == '=':
                self.lookAhead() # skip '='
                node = Assign('=', sym, self.parseExpression())
            elif ttype == TokenType.IADD:
                self.lookAhead() # skip '+='
                node = Assign(TokenType.IADD, sym, self.parseExpression())
            elif ttype == TokenType.ISUB:
                self.lookAhead() # skip '-='
                node = Assign(TokenType.ISUB, sym, self.parseExpression())
            elif ttype == TokenType.IMUL:
                self.lookAhead() # skip '*='
                node = Assign(TokenType.IMUL, sym, self.parseExpression())
            elif ttype == TokenType.IDIV:
                self.lookAhead() # skip '/='
                node = Assign(TokenType.IDIV, sym, self.parseExpression())
            else:
                node = sym
        elif ttype == TokenType.QUOTES:
            node = self.parseMessage()
            self.lookAhead()
        elif ttype == TokenType.GOTO:
            node = Goto(self.lexer.token, self.lexer.getLineno())
            self.lookAhead()
        elif ttype == TokenType.CALL:
            node = Call(self.lexer.token, self.lexer.getLineno())
            self.lookAhead()
        elif ttype == TokenType.LABEL:
            node = Label2(self.lexer.token)
            self.lookAhead()
        elif ttype == TokenType.SYMBOL:
            token = self.lexer.token
            ttype = self.lookAhead()
            if ttype == '(':
                # 関数呼び出しの解析
                node = self.parseMethodCall(token)
            elif self.hasDefines(token):
                # 定数の解析
                node = Define(self.getDefines(token))
            elif self.hasKeyword(token):
                # キーワードの解析
                node = Keyword(self.getKeywords(token))
            else:
                self.fatal("Illigal grammar define symbol :TokenType '%s' Token '%s'"%(ttype, token))
#            self.lookAhead()
        elif ttype == TokenType.CRLF:
            # 空行
            node = None
        elif ttype == ';':
            # 行の終わり
            node = None
        elif ttype == '}':
            # ブロックの終了
            node = None
        else:
            self.fatal("Illigal TokenType '%s'"%ttype)
        return node
    def parseMessage(self):
        """ メッセージの解析 """
        token = self.lexer.token.strip('"')
        suffix = token[len(token)-1]
        if suffix == "¥¥":
            # 改行エスケープ
            message = token[:len(token)-1]
            while True:
                ttype = self.lookAhead()
                if ttype != TokenType.CRLF:
                    self.fatal("Message in Illigal TokenType '%s'"%ttype)
                ttype = self.lookAhead()
                if ttype != TokenType.QUOTES:
                    self.fatal("Message in Illigal TokenType '%s'"%ttype)
                token = self.lexer.token.strip('"')
                suffix = token[len(token)-1]
                if suffix == "¥¥":
                    message += token[:len(token)-1]
                else:
                    message += token
                    break
        else:
            message = token
        return Message(message)
    def parseVar(self):
        """ 変数の解析 """
        no = self.lexer.token.lstrip("$")
        return Var(no)
    def parseMethodCall(self, token):
        """ 関数呼び出しの解析 """
        self.lookAhead() # skip '('
        args = self.parseArgs()
        if self.getTokenType() != ')':
            self.fatal("Illigal TokenType '%s'"%self.getTokenType())
        self.lookAhead()

        if self.hasGlobals(token):
            settings = self.globals[token]
            result = Primitive(settings, args)
        else:
            self.fatal("Not define symbol '%s'"%token)
        return result
    def parseArgs(self):
        """ 引数リストの解析
        # 引数の並び ← [ 式 [',' 式]* ]
        """
        result = []
        if self.getTokenType() != ')':
            result.append(self.parseExpression())
            ttype = self.getTokenType()
            while ttype != ')':
                if ttype != ',':
                    self.fatal("Illigal args statement '%s'"%ttype)
                ttype = self.lookAhead() # skip ','
                result.append(self.parseExpression())
                ttype = self.getTokenType()
        return result
