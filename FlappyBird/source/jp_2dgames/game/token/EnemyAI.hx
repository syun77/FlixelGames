package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.AdvScript;

/**
 * 敵のAI
 **/
class EnemyAI {

  // 主体者
  var _self:Enemy;

  // スクリプト実行
  var _script:AdvScript;

  // 一時停止タイマー
  var _tWait:Float = 0.0;

  // ログ出力
  var _bLog:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(self:Enemy, script:String) {

    _self = self;

    // コールバックテーブル
    var tbl = [
      "BULLET" => _BULLET,
      "BULLET2"=> _BULLET2,
      "ENEMY"  => _ENEMY,
      "WAIT"   => _WAIT,
      "AIM"    => _AIM,
      "DECAY"  => _DECAY,
      "MOVE"   => _MOVE,
      "DESTROY"=> _DESTROY,
      "RANK"   => _RANK,
      "REFLECT"=> _REFLECT,
      "RND"    => _RND,
      "LOT"    => _LOT,
      "LOG"    => _LOG,
      "SIN"    => _SIN,
    ];
    // プログラムカウンタを初期化
    _script = new AdvScript(tbl, script);
  }

  /**
   * ログ有効フラグを設定する
   **/
  public function setLog(b:Bool):Void {
    _bLog = b;
  }

  /**
   * スクリプト実行
   **/
  public function exec(elapsed:Float):Void {

    if(_tWait > 0) {
      // 実行停止中
      _tWait -= elapsed;
      return;
    }
    _script.update();
    if(_script.isEnd()) {
      // 終端になったら最初に戻す
      _script.resetPc();
    }
  }

  /**
   * ログの出力
   **/
  function _log(msg:String):Void {
    if(_bLog) {
      trace(msg);
    }
  }

  // -----------------------------------------------
  // ■各種コマンド
  // 弾を撃つ
  function _BULLET(param:Array<String>):Int {
    _log('[AI] BULLET');
    var deg = _script.popStack();
    var speed = _script.popStack();
    _self.bullet(deg, speed);
    return AdvScript.RET_CONTINUE;
  }
  function _BULLET2(param:Array<String>):Int {
    _log('[AI] BULLET2');
    var xofs = _script.popStack();
    var yofs = _script.popStack();
    var deg  = _script.popStack();
    var speed= _script.popStack();
    _self.bullet2(xofs, yofs, deg, speed);
    return AdvScript.RET_CONTINUE;
  }
  // 敵を生成
  function _ENEMY(param:Array<String>):Int {
    _log('[AI] ENEMY');
    var eid = _script.popStack();
    var deg = _script.popStack();
    var speed = _script.popStack();
    Enemy.add(eid, _self.attribute, _self.xcenter, _self.ycenter, deg, speed);
    return AdvScript.RET_CONTINUE;
  }
  // 少し停止する
  function _WAIT(param:Array<String>):Int {
    _log('[AI] WAIT');
    var time = _script.popStack();
    _tWait = time / 1000;
    return AdvScript.RET_YIELD;
  }
  // 狙い撃ち角度を取得
  function _AIM(param:Array<String>):Int {
    _log('[AI] AIM');
    var aim = _self.getAim();
    _script.pushStack(Std.int(aim));
    return AdvScript.RET_CONTINUE;
  }
  // 移動減衰値を設定
 function _DECAY(param:Array<String>):Int {
    _log('[AI] DECAY');
    var decay = _script.popStack();
    _self.setDecay(decay * 0.01);
    return AdvScript.RET_CONTINUE;
  }
  // 移動速度を設定
  function _MOVE(param:Array<String>):Int {
    _log('[AI] MOVE');
    var deg = _script.popStack();
    var speed = _script.popStack();
    _self.setVelocity(deg, speed);
    return AdvScript.RET_CONTINUE;
  }
  // 自爆
  function _DESTROY(param:Array<String>):Int {
    _log('[AI] DESTROY');
    _self.selfDestruction();
    return AdvScript.RET_YIELD;
  }
  // ランク
  function _RANK(param:Array<String>):Int {
    _log('[AI] RANK');
    _script.pushStack(Global.level);
    return AdvScript.RET_CONTINUE;
  }
  // 画面端で跳ね返るかどうか
  function _REFLECT(param:Array<String>):Int {
    _log('[AI] REFLECT');
    _self.setReflect(true);
    return AdvScript.RET_CONTINUE;
  }
  // 乱数
  function _RND(param:Array<String>):Int {
    _log('[AI] RND');
    var rnd = _script.popStack();
    var val = FlxG.random.int(0, rnd);
    _script.pushStack(val);
    return AdvScript.RET_CONTINUE;
  }
  // くじ引き
  function _LOT(param:Array<String>):Int {
    _log('[AI] ROT');
    var rot = _script.popStack();
    _script.pushStackBool(FlxG.random.bool(rot));
    return AdvScript.RET_CONTINUE;
  }
  // 正弦
  function _SIN(param:Array<String>):Int {
    _log('[AI] SIN');
    var val = _script.popStack();
    var deg = _script.popStack();
    var ret = val * MyMath.sinEx(deg);
    _script.pushStack(Std.int(ret));
    return AdvScript.RET_CONTINUE;
  }
  // ログ出力
  function _LOG(param:Array<String>):Int {
    var p0 = _script.popStack();
    var prev = _bLog;
    _bLog = (p0 != 0);
    var sysLog = (p0 == 2);
    _script.setLog(sysLog);
    if(prev || _bLog) {
      _log('[AI] LOG ${p0}');
    }

    return AdvScript.RET_CONTINUE;

  }
}
