package jp_2dgames.game;

import flixel.FlxBasic;
import flixel.addons.util.FlxFSM;

/**
 * フィールドイベント
 **/
private enum FieldEvent {
  None;    // 何も起こらなかった
  Encount; // 敵出現
  Itemget; // アイテム獲得
  Stair;   // 階段を見つけた
}

/**
 * シーケンス管理
 **/
class SeqMgr extends FlxBasic {

  public static inline var RET_NONE:Int    = 0;
  public static inline var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static inline var RET_STAGECLEAR:Int  = 5; // ステージクリア

  static inline var TIMER_WAIT:Int = 30;

  var _tWait:Int = 0;
  var _bDead:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }


  /**
   * 更新
   **/
  public function proc():Int {
    return RET_NONE;
  }

  // ------------------------------------------------------
  // ■アクセサ
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * FSMの遷移条件
 **/
private class Conditions {
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * 各FSMの実装
**/
// ゲーム開始
private class Boot extends FlxFSMState<SeqMgr> {
}
