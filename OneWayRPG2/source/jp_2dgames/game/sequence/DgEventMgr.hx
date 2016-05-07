package jp_2dgames.game.sequence;

import jp_2dgames.game.global.Global;
import jp_2dgames.game.gui.message.Msg;
import flixel.FlxG;
import jp_2dgames.game.gui.message.Message;

/**
 * ダンジョンイベント
 **/
enum DgEvent {
  None;    // 何も起こらなかった
  Encount; // 敵出現
  Itemget; // アイテム獲得
  Stair;   // 階段を見つけた
}

class DgEventMgr {

  // ■デバッグ用定数
  // 敵をすぐに出現させるかどうか
  static inline var ENEMYENCOUNT_QUICK:Bool = false;

  // 発生したイベント
  static var _event:DgEvent;
  // 階段出現までのカウンタ
  //static var _cntStair:Int;
  // 階段を見つけたかどうか
  static var _bStair:Bool;
  // 敵出現カウンタ
  static var _cntEnemyEncount:Int;
  // アイテム出現カウンタ
  static var _cntItemGain:Int;

  // ----------------------------
  // ■アクセサ
  public static var event(get, never):DgEvent;

  /**
   * 初期化
   **/
  public static function init():Void {
    _event = DgEvent.None;
    //_cntStair = 0;
    _bStair = false;
    resetEnemyEncount();
    resetItemGain();

    FlxG.watch.add(DgEventMgr, "_cntStair");
    FlxG.watch.add(DgEventMgr, "_cntEnemyEncount");
    FlxG.watch.add(DgEventMgr, "_cntItemGain");
  }

  /**
   * イベントの抽選を行う
   **/
  public static function lottery():Void {

    if(Global.step <= 0) {
      // ボス出現
      // 敵出現
      _event = DgEvent.Encount;
      // エンカウントカウンタ初期化
      resetEnemyEncount();
      // 階段出現
      _bStair = true;
      return;
    }

    /*
    if(_bStair == false) {
      // 階段カウンター更新
      _cntStair += FlxG.random.int(3, 7);
      if(_cntStair > 100) {
        // 階段出現
        _event = DgEvent.Stair;
        _bStair = true;
        Message.push2(Msg.FIND_NEXTFLOOR);
        return;
      }
    }
    */

    // アイテム入手カウンタ更新
    _cntItemGain += FlxG.random.int(10, 20);
    if(_cntItemGain >= 100) {
      // アイテム出現
      _event = DgEvent.Itemget;
      // アイテム出現カウンタ初期化
      resetItemGain();
      return;
    }

    // 敵出現カウンタ更新
    _cntEnemyEncount += FlxG.random.int(10, 20);
    if(_cntEnemyEncount >= 100) {
      // 敵出現
      _event = DgEvent.Encount;
      // エンカウントカウンタ初期化
      resetEnemyEncount();
      return;
    }

    var rnd = FlxG.random.float(0, 99);
    if(rnd < 10) {
      // 敵出現
      _event = DgEvent.Encount;
    }
    else if(rnd < 20) {
      // アイテム獲得
      _event = DgEvent.Itemget;
    }
    else {
      // 何も起きない
      //Message.push2(Msg.NOTHING_FIND);
      _event = DgEvent.None;
    }
  }

  /**
   * 階段を見つけたかどうか
   **/
  public static function isFoundStair():Bool {
    return _bStair;
  }

  /**
   * 敵のエンカウントカウンタを初期化
   **/
  public static function resetEnemyEncount():Void {
    _cntEnemyEncount = 0;
    if(ENEMYENCOUNT_QUICK) {
      _cntEnemyEncount = 100;
    }
  }

  /**
   * アイテム入手カウンタを初期化
   **/
  public static function resetItemGain():Void {
    _cntItemGain = 0;
  }

  // ----------------------------------------
  // ■アクセサメソッド
  static function get_event() { return _event; }
}