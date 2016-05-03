package jp_2dgames.game;

import flixel.FlxG;
import jp_2dgames.game.sequence.Dg;
import flash.display3D.Context3D;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
import flixel.FlxBasic;
import flixel.addons.util.FlxFSM;


/**
 * シーケンス管理
 **/
class SeqMgr extends FlxBasic {

  public static inline var RET_NONE:Int    = 0;
  public static inline var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static inline var RET_STAGECLEAR:Int  = 5; // ステージクリア

  static inline var TIMER_WAIT:Int = 30;

  // -----------------------------------------
  // ■フィールド
  var _tWait:Int = 0;
  var _bDead:Bool = false;

  // FSM
  var _fsm:FlxFSM<SeqMgr>;
  var _fsmName:String = ""; // 名前(デバッグ用)

  // アクター
  var _player:Actor;
  var _enemy:Actor;

  // -----------------------------------------
  // ■アクセサ
  public var player(get, never):Actor;
  public var enemy(get, never):Actor;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _player = ActorMgr.getPlayer();
    _enemy  = ActorMgr.getEnemy();
    _enemy.visible = false;

    _fsm = new FlxFSM<SeqMgr>(this);
    // 状態遷移テーブル
    _fsm.transitions
      .add(Boot, Dg, Conditions.isEndWait) // 開始 -> ダンジョン
      // ここまで
      .start(Boot);
    _fsm.stateClass = Boot;

    FlxG.watch.add(this, "_fsmName", "fsm");
    FlxG.watch.add(this, "_lastClickButton", "button");
    FlxG.watch.add(this, "_lastOverlapButton", "over");
    FlxG.watch.add(this, "_tWait", "tWait");

  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_tWait > 0) {
      _tWait--;
    }
    _fsm.update(elapsed);
    _fsmName = Type.getClassName(_fsm.stateClass);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  public function isEndWait():Bool {
    return true;
  }


  /**
   * 更新
   **/
  public function proc():Int {
    return RET_NONE;
  }

  // ------------------------------------------------------
  // ■アクセサメソッド
  function get_player() { return _player; }
  function get_enemy()  { return _enemy;  }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * FSMの遷移条件
 **/
private class Conditions {
  public static function isEndWait(owner:SeqMgr):Bool {
    return owner.isEndWait();
  }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * 各FSMの実装
**/
// ゲーム開始
private class Boot extends FlxFSMState<SeqMgr> {
}
