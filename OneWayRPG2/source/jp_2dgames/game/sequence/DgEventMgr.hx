package jp_2dgames.game.sequence;

/**
 * ダンジョンイベント
 **/
import jp_2dgames.game.gui.message.Msg;
import flixel.FlxG;
import jp_2dgames.game.gui.message.Message;
enum DgEvent {
  None;    // 何も起こらなかった
  Encount; // 敵出現
  Itemget; // アイテム獲得
  Stair;   // 階段を見つけた
}

class DgEventMgr {

  // 発生したイベント
  static var _event:DgEvent;
  // 階段出現までのカウンタ
  static var _cntStair:Int;
  // 階段を見つけたかどうか
  static var _bStair:Bool;

  // ----------------------------
  // ■アクセサ
  public static var event(get, never):DgEvent;

  /**
   * 初期化
   **/
  public static function init():Void {
    _event = DgEvent.None;
    _cntStair = 0;
    _bStair = false;
  }

  /**
   * イベントの抽選を行う
   **/
  public static function lottery():Void {

    if(_bStair == false) {
      // 階段カウンター更新
      _cntStair += FlxG.random.int(3, 7);
      if(_cntStair > 40) {
        // 階段出現
        _event = DgEvent.Stair;
        _bStair = true;
        Message.push2(Msg.FIND_NEXTFLOOR);
        return;
      }
    }

    var rnd = FlxG.random.float(0, 99);
    // TODO:
    rnd = 10;
    if(rnd < 20) {
      // 敵出現
      _event = DgEvent.Encount;
    }
    else if(rnd < 40) {
      // アイテム獲得
      _event = DgEvent.Itemget;
    }
    else {
      // 何も起きない
      Message.push2(Msg.NOTHING_FIND);
      _event = DgEvent.None;
    }
  }

  // ----------------------------------------
  // ■アクセサメソッド
  static function get_event() { return _event; }
}