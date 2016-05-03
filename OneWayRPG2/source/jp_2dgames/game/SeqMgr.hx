package jp_2dgames.game;

import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.sequence.DgEvent;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import jp_2dgames.game.sequence.Dg;
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

  // ダンジョンイベント
  var _event:DgEvent = DgEvent.None;

  // アクター
  var _player:Actor;
  var _enemy:Actor;

  // ボタン関連
  var _overlapedItem:Int = -1;
  var _lastOverlapButton:String = ""; // 最後にオーバーラップしたボタン
  var _lastClickButton:String = ""; // 最後にクリックしたボタン

  // -----------------------------------------
  // ■アクセサ
  public var player(get, never):Actor;
  public var enemy(get, never):Actor;
  public var lastOverlapButton(get, never):String;
  public var lastClickButton(get, never):String;

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
      // 開始
      .add(Boot,   Dg,     Conditions.isEndWait) // 開始 -> ダンジョン
      // ダンジョン
      .add(Dg,     DgRest, Conditions.isRest)    // ダンジョン -> 休憩
      // ダンジョン - 休憩
      .add(DgRest, Dg,     Conditions.isEndWait) // 休憩 -> ダンジョン
      // ここまで
      .start(Boot);
    _fsm.stateClass = Boot;

    // ボタンのコールバックを設定
    BattleUI.setButtonClickCB(_cbButtonClick);
    BattleUI.setButtonOverlapCB(_cbButtonOverlap);

    FlxG.watch.add(this, "_fsmName", "fsm");
    FlxG.watch.add(this, "_lastClickButton", "button");
    FlxG.watch.add(this, "_lastOverlapButton", "over");
    FlxG.watch.add(this, "_tWait", "tWait");

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    _fsm = FlxDestroyUtil.destroy(_fsm); // FlxStateに登録しないので手動で破棄が必要
    super.destroy();
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
   * 少し待つ
   **/
  public function startWait():Void {
    _tWait = TIMER_WAIT;
  }

  /**
   * 待ちが終了したかどうか
   **/
  public function isEndWait():Bool {
    return _tWait <= 0;
  }

  /**
   * オーバーラップしたボタンのコールバック
   **/
  function _cbButtonOverlap(name:String):Void {
    _lastOverlapButton = name;
    var idx = Std.parseInt(_lastOverlapButton);
    if(idx != null) {
      // 詳細情報の更新
      var item = ItemList.getFromIdx(idx);
      _overlapedItem = item.uid;
      var detail = ItemUtil.getDetail2(item);
      BattleUI.setDetailText(detail);
    }
  }

  /**
   * クリックしたボタンのコールバック
   **/
  function _cbButtonClick(name:String):Void {
    _lastClickButton = name;
  }

  /**
   * 最後にクリックしたボタンをリセット
   **/
  public function resetLastClickButton():Void {
    _lastClickButton = "";
    _overlapedItem = -1;
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
  function get_lastOverlapButton() { return _lastOverlapButton; }
  function get_lastClickButton() { return _lastClickButton; }
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
  public static function isSearch(owner:SeqMgr):Bool {
    return owner.lastClickButton == "search";
  }
  public static function isRest(owner:SeqMgr):Bool {
    return owner.lastClickButton == "rest";
  }
  public static function isItemDel(owner:SeqMgr):Bool {
    return owner.lastClickButton == "itemdel";
  }
  public static function isNextFloor(owner:SeqMgr):Bool {
    return owner.lastClickButton == "nextfloor";
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
