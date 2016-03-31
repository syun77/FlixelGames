package jp_2dgames.lib;

import flixel.FlxG;
import openfl.Assets;

/**
 * ADVゲーム用スクリプト
 **/
class AdvScript {

  // ■定数
  public static inline var RET_CONTINUE:Int = 0;
  public static inline var RET_YIELD:Int    = 1;

  // 代入演算子
  public static inline var ASSIGN_NON:Int = 0;
  public static inline var ASSIGN_ADD:Int = 1;
  public static inline var ASSIGN_SUB:Int = 2;
  public static inline var ASSIGN_MUL:Int = 3;
  public static inline var ASSIGN_DIV:Int = 4;


  // 変数の最大数
  public static inline var MAX_VAR:Int = 16;

  // ■スタティック

  // ■メンバ変数
  // スクリプトデータ
  var _data:Array<String>;
  // 実行カウンタ
  var _pc:Int;
  // 終了コードが見つかったかどうか
  var _bEnd:Bool;
  // システムコマンド定義
  var _sysTbl:Map<String,Array<String>->Void>;
  // ユーザコマンド定義
  var _userTbl:Map<String,Array<String>->Int>;
  // ログを出力するかどうか
  var _bLog:Bool = false;
  // 変数
  var _vars:Array<Int>;
  public function setVar(idx:Int, v:Int):Void {
    if(idx < 0 || _vars.length <= idx) {
      // 範囲外
      return;
    }
    _vars[idx] = v;
  }
  public function getVar(idx:Int):Int {
    if(idx < 0 || _vars.length <= idx) {
      // 範囲外
      return 0;
    }
    return _vars[idx];
  }

  // 変数スタック
  var _stack:List<Int>;
  public function popStack():Int {
    return _stack.pop();
  }
  public function pushStack(v:Int):Void {
    _stack.push(v);
  }
  public function pushStackBool(b:Bool):Void {
    _stack.push(if(b) 1 else 0);
  }

  /**
   * コンストラクタ
   **/
  public function new(cmdTbl:Map<String,Array<String>->Int>, filepath:String=null) {
    if(filepath != null) {
      // 読み込み
      load(filepath);
    }

    // システムテーブル登録
    _sysTbl = [
      "INT"   => _INT,
      "SET"   => _SET,
      "ADD"   => _ADD,
      "SUB"   => _SUB,
      "MUL"   => _MUL,
      "DIV"   => _DIV,
      "NEG"   => _NEG,
      "VAR"   => _VAR,
      "EQ"    => _EQ,
      "NE"    => _NE,
      "LE"    => _LE,
      "LESS"  => _LESS,
      "GE"    => _GE,
      "AND"   => _AND,
      "OR"    => _OR,
      "GREATER" => _GREATER,
      "IF"    => _IF,
      "GOTO"  => _GOTO,
      "WHILE" => _WHILE,
      "END"   => _END,
    ];

    _userTbl = cmdTbl;
    _stack   = new List<Int>();
    _vars    = new Array<Int>();
    for(i in 0...MAX_VAR) {
      _vars.push(0);
    }
  }

  /**
   * 読み込み
   **/
  public function load(filepath):Void {
    var scr:String = Assets.getText(filepath);
    if(scr == null) {
      // 読み込み失敗
      FlxG.log.warn("AdvScript.load() scr is null. file:'" + filepath + "''");
      return;
    }

    // 変数初期化
    _data = scr.split("\n");
    _pc   = 0;
    _bEnd = false;
  }

  /**
   * ログを有効化するかどうか
   **/
  public function setLog(b:Bool):Void {
    _bLog = b;
  }

  /**
   * 実行カウンタを最初に戻す
   **/
  public function resetPc():Void {
    _pc = 0;
    _bEnd = false;
  }

  /**
   * 終了したかどうか
   **/
  public function isEnd():Bool {
    if(_bEnd) {
      return true;
    }
    return _pc >= _data.length;
  }

  /**
   * 更新
   **/
  public function update():Void {
    while(isEnd() == false) {
      var ret = _loop();
      if(ret == RET_YIELD) {
        // いったん抜ける
        break;
      }
    }
  }

  /**
   * ループ
   **/
  private function _loop():Int {
    var line = _data[_pc];
    if(line == "") {
      _pc++;
      return RET_CONTINUE;
    }

    var d = line.split(",");
    _pc++;
    var cmd = d[0];
    var param = d.slice(1);

    var ret = RET_CONTINUE;

    if(_sysTbl.exists(cmd)) {
      _sysTbl[cmd](param);
      ret = RET_CONTINUE;
    }
    else {
      if(_userTbl.exists(cmd) == false) {
        throw 'Error: Not found command = ${cmd}';
      }
      ret = _userTbl[cmd](param);
    }

    return ret;
  }

  private function _INT(param:Array<String>):Void {
    var p0 = Std.parseInt(param[0]);
    if(_bLog) {
      trace('[AI] INT ${p0}');
    }
    pushStack(p0);
  }
  private function _SET(param:Array<String>):Void {
    var op  = Std.parseInt(param[0]);
    var idx = Std.parseInt(param[1]);
    var val = popStack();
    var result = getVar(idx);
    var log = "";
    switch(op) {
      case ASSIGN_NON:
        result = val;
        log = '$$${idx}=${val}';
      case ASSIGN_ADD:
        result += val;
        log = '$$${idx}+=${val}';
      case ASSIGN_SUB:
        result -= val;
        log = '$$${idx}-=${val}';
      case ASSIGN_MUL:
        result *= val;
        log = '$$${idx}*=${val}';
      case ASSIGN_DIV:
        result = Std.int(result / val);
        log = '$$${idx}/=${val}';
    }
    if(_bLog) {
      trace('[AI] SET ${log}');
    }
    setVar(idx, result);
  }

  private function _ADD(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI ADD ${left} + ${right} => push ${left+right}');
    }
    pushStack(left + right);
  }

  private function _SUB(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI SUB ${left} - ${right} => push ${left-right}');
    }
    pushStack(left - right);
  }

  private function _MUL(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI MUL ${left} * ${right} => push ${left*right}');
    }
    pushStack(left * right);
  }

  private function _DIV(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI MUL ${left} / ${right} => push ${Std.int(left/right)}');
    }
    pushStack(Std.int(left / right));
  }

  private function _NEG(param:Array<String>):Void {
    var val = popStack();
    if(_bLog) {
      trace('[AI] NEG ${val} => push ${-val}');
    }
    pushStack(-val);
  }

  private function _VAR(param:Array<String>):Void {
    var idx = Std.parseInt(param[0]);
    var val = getVar(idx);
    pushStack(val);
    if(_bLog) {
      trace('[AI] VAR $$${idx} is ${val} push ${_vars}');
    }
  }

  // '=='
  private function _EQ(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] EQ ${left} == ${right}');
    }
    pushStackBool(left == right);
  }

  // '!='
  private function _NE(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] NE ${left} != ${right}');
    }
    pushStackBool(left != right);
  }

  // '<'
  private function _LE(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] LE ${left} < ${right}');
    }
    pushStackBool(left < right);
  }
  // '<='
  private function _LESS(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] LESS ${left} < ${right}');
    }
    pushStackBool(left <= right);
  }
  // '>'
  private function _GE(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] GE ${left} > ${right}');
    }
    pushStackBool(left > right);
  }
  // '>='
  private function _GREATER(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] GREATER ${left} >= ${right}');
    }
    pushStackBool(left >= right);
  }
  // '&&'
  private function _AND(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] AND ${left} && ${right}');
    }
    pushStackBool(left != 0 && right != 0);
  }
  // '||'
  private function _OR(param:Array<String>):Void {
    var right = popStack();
    var left  = popStack();
    if(_bLog) {
      trace('[AI] OR ${left} || ${right}');
    }
    pushStackBool(left != 0 || right != 0);
  }

  private function _IF(param:Array<String>):Void {
    var val = popStack();
    if(_bLog) {
      trace('[AI] IF ${val}');
    }
    if(val == 0) {
      // 演算結果が偽なのでアドレスジャンプ
      var address = Std.parseInt(param[0]);
      _jump(address);
    }
  }

  private function _GOTO(param:Array<String>):Void {
    var address = Std.parseInt(param[0]);
    if(_bLog) {
      trace('[AI] GOTO ${address}');
    }
    _jump(address);
  }

  private function _WHILE(param:Array<String>):Void {
    /*
    var val = popStack();
    if(_bLog) {
      trace('[AI] WHILE ${val}');
    }
    if(val == 0) {
      // 演算結果が偽なのでアドレスジャンプ
      var address = Std.parseInt(param[0]);
      _jump(address);
    }
    */
  }

  private function _jump(address:Int):Void {
    if(_bLog) {
      trace('[AI] JUMP now(${_pc}) -> next(${address})');
    }

    // アドレスは -1 した値
    _pc = address - 1;
  }

  private function _END(param:Array<String>):Void {
    if(_bLog) {
      trace("[AI] END");
      trace("-------------------");
    }
    _bEnd = true;
  }
}
