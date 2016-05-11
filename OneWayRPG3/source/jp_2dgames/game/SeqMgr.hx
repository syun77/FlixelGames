package jp_2dgames.game;

import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.dat.ResistData.ResistList;
import jp_2dgames.game.sequence.btl.BtlLogicPlayer;
import jp_2dgames.game.sequence.Btl;
import jp_2dgames.game.sequence.DgEventMgr;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.item.ItemList;
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

  // 選択したアイテム情報
  var _selectedItem:Int;

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
      // ■開始
      .add(Boot,       Dg,          Conditions.isEndWait)   // 開始 -> ダンジョン

      // ■ダンジョン
      .add(Dg,         DgSearch,    Conditions.isSearch)    // ダンジョン    -> 探索
      .add(Dg,         DgRest,      Conditions.isRest)      // ダンジョン    -> 休憩
      .add(Dg,         DgDrop,      Conditions.isItemDel)   // ダンジョン    -> アイテム捨てる
      .add(Dg,         DgUpgrade,   Conditions.isPowerUp)   // ダンジョン    -> 強化
      .add(Dg,         DgNextFloor, Conditions.isNextFloor) // ダンジョン    -> 次のフロアに進む
      // ダンジョン - 探索
      .add(DgSearch,   DgSearch2,   Conditions.isEndWait)   // 探索中...    -> 探索実行
      .add(DgSearch2,  BtlBoot,     Conditions.isAppearEnemy) // 探索中...  -> 敵に遭遇
      .add(DgSearch2,  DgGain,      Conditions.isItemGain)  // 探索中...    -> アイテム獲得
      .add(DgSearch2,  DgSearch,    Conditions.isEventNone) // 探索中...    -> 再び探索
      .add(DgSearch2,  Dg,          Conditions.isEndWait)   // 探索中...    -> ダンジョンに戻る
      // ダンジョン - 探索 - アイテム獲得
      .add(DgGain,     DgItemFull,  Conditions.isItemFull)  // アイテム獲得  -> アイテム一杯
      .add(DgGain,     Dg,          Conditions.isEndWait)   // アイテム獲得  -> ダンジョンに戻る
      // ダンジョン - 探索 - アイテム一杯
      .add(DgItemFull, Dg,          Conditions.isIgnore)    // アイテム一杯  -> ダンジョンに戻る
      .add(DgItemFull, Dg,          Conditions.isSelectItem)// アイテム一杯  -> ダンジョンに戻る

      // ダンジョン - 休憩
      .add(DgRest,    Dg,          Conditions.isEndWait)   // 休憩         -> ダンジョン
      // ダンジョン - 強化
      .add(DgUpgrade, Dg,          Conditions.isEndWait)   // 強化         -> ダンジョン
      // ダンジョン - アイテム捨てる
      .add(DgDrop,    Dg,          Conditions.isEndWait)
      .add(DgDrop,    Dg,          Conditions.isCancel)    // アイテム破棄  -> キャンセル
      .add(DgDrop,    DgDrop2,     Conditions.isSelectItem)// アイテム破棄  -> アイテム捨てる
      .add(DgDrop2,   Dg,          Conditions.isEndWait)   // アイテム破棄  -> ダンジョン

      // ■バトル
      .add(BtlBoot,        Btl,            Conditions.isEndWait)    // 敵出現        -> バトルコマンド入力
      .add(Btl,            BtlPlayerBegin, Conditions.isSelectItem) // コマンド      -> プレイヤー開始
      .add(Btl,            BtlPlayerBegin, Conditions.isEmpytItem)  // コマンド      -> アイテムがないので自動攻撃
      // バトル - プレイヤー行動
      .add(BtlPlayerBegin, BtlPlayerMain,  Conditions.isEndWait)    // プレイヤー開始 -> プレイヤー実行
      .add(BtlPlayerMain,  BtlEnemyDead,   Conditions.isDeadEnemy)  // プレイヤー実行 -> 敵死亡
      .add(BtlPlayerMain,  BtlEnemyBegin,  Conditions.isLogicEnd)   // プレイヤー実行 -> 敵開始
      // バトル - 敵行動
      .add(BtlEnemyBegin,  BtlEnemyMain,   Conditions.isEndWait)    // 敵開始        -> 敵実行
      .add(BtlEnemyMain,   BtlLose,        Conditions.isDead)       // 敵実行        -> 敗北 (※ゲームオーバー)
      .add(BtlEnemyMain,   BtlTurnEnd,     Conditions.isLogicEnd)   // 敵実行        -> ターン終了
      // バトル - ターン終了
      .add(BtlTurnEnd,     Btl,            Conditions.isEndWait)    // ターン終了     -> バトルコマンド入力
      // バトル - 勝利
      .add(BtlEnemyDead,   BtlPowerup,     Conditions.isEndWait)    // 敵死亡        -> アイテム強化
      .add(BtlPowerup,     BtlWin,         Conditions.isEndWait)    // アイテム強化   -> 勝利
      .add(BtlWin,         BtlItemGet,     Conditions.isEndWait)    // 勝利          -> アイテム獲得
      // バトル - アイテム獲得
      .add(BtlItemGet,     BtlEnd,         Conditions.isEndWait)    // アイテム獲得   -> バトル終了
      // バトル - 探索 - アイテム一杯
      .add(BtlItemFull,    BtlEnd,         Conditions.isIgnore)     // アイテム一杯   -> バトル終了
      .add(BtlItemFull,    BtlEnd,         Conditions.isSelectItem) // アイテム一杯   -> バトル終了
      // バトル - 逃走
      .add(BtlEscape,      BtlEnd,         Conditions.isEndWait)    // 逃走          -> バトル終了
      // バトル - 敗北
      // ※ゲームオーバーなので遷移しない
      // バトル - 終了
      .add(BtlEnd,         Dg,             Conditions.isEndWait)    // バトル終了     -> ダンジョンに戻る

      // ここまで
      .start(Boot);
    _fsm.stateClass = Boot;

    // ボタンのコールバックを設定
    BattleUI.setButtonClickCB(_cbButtonClick);
    BattleUI.setButtonOverlapCB(_cbButtonOverlap);

    // 初期化処理
    // イベント初期化
    DgEventMgr.init();

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

  public function startWaitHalf():Void {
    _tWait = Std.int(TIMER_WAIT/2);
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
      // 耐性情報
      var resists:ResistList = null;
      if(enemy.visible) {
        resists = EnemyDB.getResists(enemy.id);
      }
      var detail = ItemUtil.getDetail2(this, item, resists);
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
   * 選択したアイテム
   **/
  public function getSelectedItem():ItemData {
    return ItemList.getFromUID(_selectedItem);
  }

  /**
   * クリックしたボタンをアイテムリストのUIに変換する
   **/
  public function trySetClickButtonToSelectedItem():Bool {
    var id = lastClickButton;
    var idx = Std.parseInt(id);
    if(idx != null) {
      // アイテムを選んだ
      var item = ItemList.getFromIdx(idx);
      _selectedItem = item.uid;
      return true;
    }
    // アイテム以外を選んだ
    return false;

  }


  /**
   * 更新
   **/
  public function proc():Int {
    return switch(_fsm.stateClass) {
      case BtlLose:
        // 死亡
        return RET_DEAD;
      case DgNextFloor:
        // 次のフロアに進む
        return RET_STAGECLEAR;
      default:
        RET_NONE;
    }
  }

  /**
   * 食糧を増やす
   **/
  public function addFood(v:Int):Void {
    player.addFood(v);
    Message.push2(Msg.FOOD_ADD, [v]);
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

  public static function isFoundStair(owner:SeqMgr):Bool {
    return DgEventMgr.isFoundStair();
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
  public static function isPowerUp(owner:SeqMgr):Bool {
    return owner.lastClickButton == "powerup";
  }
  public static function isNextFloor(owner:SeqMgr):Bool {
    return owner.lastClickButton == "nextfloor";
  }
  public static function isSelectItem(owner:SeqMgr):Bool {
    if(owner.trySetClickButtonToSelectedItem()) {
      // アイテム選んだ
      return true;
    }
    // 選んでない
    return false;
  }
  public static function isCancel(owner:SeqMgr):Bool {
    return owner.lastClickButton == "cancel";
  }
  public static function isIgnore(owner:SeqMgr):Bool {
    return owner.lastClickButton == "ignore";
  }
  public static function isAppearEnemy(owner:SeqMgr):Bool {
    // 敵に遭遇したかどうか
    return DgEventMgr.event == DgEvent.Encount;
  }
  public static function isItemGain(owner:SeqMgr):Bool {
    // アイテム獲得したかどうか
    return DgEventMgr.event == DgEvent.Itemget;
  }
  public static function isItemFull(owner:SeqMgr):Bool {
    // アイテムが一杯かどうか
    return ItemList.isFull();
  }
  // イベントが発生していないかどうか
  public static function isEventNone(owner:SeqMgr):Bool {
    if(DgEventMgr.event == DgEvent.None) {
      // イベントなし
      if(owner.player.food > 0) {
        // 食糧がまだある
        return true;
      }
    }

    // なんらかのイベントが発生
    return false;
  }

  public static function isLogicEnd(owner:SeqMgr):Bool {
    if(owner.isEndWait() == false) {
      return false;
    }
    return BtlLogicPlayer.isEnd();
  }

  public static function isDeadEnemy(owner:SeqMgr):Bool {
    if(isEndWait(owner) == false) {
      return false;
    }
    return owner.enemy.isDead();
  }

  public static function isDead(owner:SeqMgr):Bool {
    if(isEndWait(owner) == false) {
      return false;
    }
    return owner.player.isDead();
  }

  // アイテムを所持していないかどうか
  public static function isEmpytItem(owner:SeqMgr):Bool {
    if(ItemList.isEmpty()) {
      return true;
    }
    return false;
  }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * 各FSMの実装
**/
// ゲーム開始
private class Boot extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // ※ここの処理はなぜか呼ばれない
  }
}

// アイテム一杯のときの捨てるメニュー
class SeqItemFull extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();
    // インベントリ表示
    BattleUI.showInventory(InventoryMode.ItemDropAndGet);
  }

  override public function exit(owner:SeqMgr):Void {
    // インベントリ非表示
    BattleUI.setVisibleGroup("inventory", false);

    var item = ItemLottery.getLastLottery();
    if(Conditions.isIgnore(owner)) {
      // あきらめたので拾ったアイテムを食糧に変換
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_ABANDAN, [name]);
      // 食糧が増える
      owner.addFood(item.now);
    }
    else {
      // 指定のアイテムを捨ててアイテム獲得
      // アイテムを手に入れた
      var item2 = owner.getSelectedItem();
      var name = ItemUtil.getName(item2);
      ItemList.del(item2.uid);
      var name2 = ItemUtil.getName(item);
      ItemList.push(item);
      Message.push2(Msg.ITEM_DEL_GET, [name, name2]);
    }
  }

}
