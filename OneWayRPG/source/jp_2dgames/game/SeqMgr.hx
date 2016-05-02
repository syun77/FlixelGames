package jp_2dgames.game;

import jp_2dgames.game.dat.ItemGain;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.dat.EnemyInfo;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.gui.BattleUI;
import flixel.util.FlxDestroyUtil;
import flixel.FlxBasic;
import flixel.addons.util.FlxFSM;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;

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

  var _fsm:FlxFSM<SeqMgr>;
  var _fsmName:String;

  var _lastOverlapButton:String = "";
  var _overlapedItem:Int = -1;
  var _lastClickButton:String = "";
  var _selectedItem:Int = 0;
  // 階段を見つけたかどうか
  var _bStair:Bool = false;

  // フィールドでのイベント
  var _event:FieldEvent = FieldEvent.None;

  var _player:Actor;
  var _enemy:Actor;

  public var player(get, never):Actor;
  public var enemy(get, never):Actor;
  public var event(get, never):FieldEvent;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _player = ActorMgr.getPlayer();
    _enemy = ActorMgr.getEnemy();
    _enemy.visible = false;

    _fsm = new FlxFSM<SeqMgr>(this);
    _fsm.transitions
      // 開始
      .add(Boot,      DgMain,       Conditions.isEndWait)    // 開始        -> フィールド
      // フィールド
      .add(DgMain,    DgSearch,     Conditions.isSearch)     // フィールド   -> 探索
      .add(DgMain,    DgRest,       Conditions.isRest)       // フィールド   -> 休憩
      .add(DgMain,    DgDrop,       Conditions.isItemDel)    // フィールド   -> アイテム捨てる
      .add(DgMain,    DgNextFloor,  Conditions.isNextFloor)  // フィールド   -> 次のフロアへ
      // フィールド - 探索
      .add(DgSearch,  Lose,         Conditions.isDead)       // 探索中……     -> プレイヤー死亡
      .add(DgSearch,  DgSearch2,    Conditions.isEndWait)    // 探索中……     -> 探索実行
      .add(DgSearch2, EnemyAppear,  Conditions.isAppearEnemy)// 探索実行     -> 敵出現
      .add(DgSearch2, DgGain,       Conditions.isItemGain)   // 探索実行     -> アイテム獲得
      .add(DgSearch2, DgMain,       Conditions.isEndWait)    // 探索実行     -> フィールドに戻る
      .add(DgGain,    DgMain,       Conditions.isEndWait)    // アイテム獲得 -> フィールドに戻る
      // フィールド - 休憩
      .add(DgRest,    DgMain,       Conditions.isEndWait)    // 休憩        -> フィールド
      // フィールド - アイテム捨てる
      .add(DgDrop,    DgMain,       Conditions.isCancel)     // アイテム破棄 -> キャンセル(フィールドに戻る)
      .add(DgDrop,    DgDrop2,      Conditions.isReadyCommand)// アイテム破棄-> アイテム捨てる
      .add(DgDrop2,   DgMain,       Conditions.isEndWait)    // アイテム破棄 -> フィールドに戻る
      // フィールド - 次のフロアに進む

      // バトル開始
      .add(EnemyAppear,  CommandInput, Conditions.isEndWait)    // 敵出現        -> キー入力
      .add(CommandInput, PlayerBegin,  Conditions.isReadyCommand) // コマンド入力 -> プレイヤー行動
      .add(CommandInput, Escape,       Conditions.isEscape)       // コマンド入力 -> 逃走
      // プレイヤー行動
      .add(PlayerBegin,  PlayerAction, Conditions.isEndWait)    // プレイヤー開始 -> プレイヤー実行
      .add(PlayerAction, Win,          Conditions.isWin)        // 勝利判定
      .add(PlayerAction, EnemyBegin,   Conditions.isEndWait)
      // 敵の行動
      .add(EnemyBegin,   EnemyAction,  Conditions.isEndWait)
      .add(EnemyAction,  Lose,         Conditions.isDead)       // 敗北判定
      .add(EnemyAction,  TurnEnd,      Conditions.isEndWait)    // 敵の行動       -> ターン終了
      // ターン終了
      .add(TurnEnd,      CommandInput, Conditions.isEndWait)    // ターン終了     -> コマンド入力
      // 勝利
      .add(Win,          ItemGet,      Conditions.isEndWait)    // 勝利          -> アイテム獲得
      // 逃走
      .add(Escape,       BtlEnd,       Conditions.isEndWait)    // 逃走          -> 戦闘終了
      // アイテム獲得
      .add(ItemGet,      BtlEnd,       Conditions.isEndWait)    // アイテム獲得   -> 戦闘終了
      .add(BtlEnd,       DgMain,    Conditions.isEndWait)    // 戦闘終了      -> フィールドに戻る
      .start(Boot);
    _fsm.stateClass = Boot;
    _fsmName = Type.getClassName(_fsm.stateClass);
    FlxG.watch.add(this, "_fsmName", "fsm");
    FlxG.watch.add(this, "_lastClickButton", "button");
    FlxG.watch.add(this, "_lastOverlapButton", "over");
    FlxG.watch.add(this, "_tWait", "tWait");

    // ボタンのコールバックを設定
    BattleUI.setButtonClickCB(_cbButtonClick);
    BattleUI.setButtonOverlapCB(_cbButtonOverlap);
  }

  /**
   * フィールドイベントを抽選
   **/
  public function checkFieldEvent():Void {
    var rnd = FlxG.random.float(0, 99);
    // TODO:
    rnd = 70;
    if(rnd < 40) {
      // 敵出現
      _event = FieldEvent.Encount;
    }
    else if(rnd < 60) {
      // 階段出現
      // TODO: 階段の出現判定は累積値で行う
      _event = FieldEvent.Stair;
      _bStair = true;
      Message.push2(Msg.FIND_NEXTFLOOR);
    }
    else if(rnd < 80) {
      // アイテム獲得
      _event = FieldEvent.Itemget;
    }
    else {
      // 何も起きない
      Message.push2(Msg.NOTHING_FIND);
      _event = FieldEvent.None;
    }
  }

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
  function _cbButtonClick(name:String):Void {
    _lastClickButton = name;
  }
  public function resetLastClickButton():Void {
    _lastClickButton = "";
  }

  public function getLastClickButton():String {
    return _lastClickButton;
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);
    if(_tWait > 0) {
      _tWait--;
    }
    _fsm.update(elapsed);
    _fsmName = Type.getClassName(_fsm.stateClass);
  }

  override public function destroy():Void {
    _fsm = FlxDestroyUtil.destroy(_fsm);
    super.destroy();
  }


  /**
   * 更新
   **/
  public function proc():Int {

    return switch(_fsm.stateClass) {
      case Lose:
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
   * 更新・メイン
   **/
  function _updateKeyInput():Void {

    if(Input.press.A) {

      if(_enemy.isDead()) {
        // 次の敵出現
        var e = new Params();
        e.id = 1;
        _enemy.init(e);
        return;
      }
    }
  }

  public function startWait():Void {
    _tWait = TIMER_WAIT;
  }

  public function isEndWait():Bool {
    return _tWait <= 0;
  }

  /**
   * 階段を見つけたかどうか
   **/
  public function isFoundStair():Bool {
    return _bStair;
  }

  /**
   * 最後にマウスオーバーしたアイテム
   **/
  public function getOverlapItem():ItemData {
    if(_overlapedItem < 0) {
      return null;
    }
    return ItemList.getFromUID(_overlapedItem);
  }
  /**
   * 選択したアイテム
   **/
  public function getSelectedItem():ItemData {
    return ItemList.getFromUID(_selectedItem);
  }
  public function setSelectedItem(uid:Int):Void {
    _selectedItem = uid;
  }

  // ------------------------------------------------------
  // ■アクセサ
  function get_player() {
    return _player;
  }
  function get_enemy() {
    return _enemy;
  }
  function get_event() {
    return _event;
  }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * FSMの遷移条件
 **/
private class Conditions {
  public static function isSearch(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "search";
  }
  public static function isRest(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "rest";
  }
  public static function isItemDel(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "itemdel";
  }
  public static function isNextFloor(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "nextfloor";
  }
  public static function isAppearEnemy(owner:SeqMgr):Bool {
    // 敵に遭遇したかどうか
    return owner.event == FieldEvent.Encount;
  }
  public static function isItemGain(owner:SeqMgr):Bool {
    // アイテム獲得したかどうか
    return owner.event == FieldEvent.Itemget;
  }
  public static function keyInput(owner:SeqMgr):Bool {
    return Input.press.A;
  }
  public static function isReadyCommand(owner:SeqMgr):Bool {
    var id = owner.getLastClickButton();
    var idx = Std.parseInt(id);
    if(idx != null) {
      // アイテムを選んだ
      var item = ItemList.getFromIdx(idx);
      owner.setSelectedItem(item.uid);
      return true;
    }
    return false;
  }
  public static function isEscape(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "escape";
  }
  public static function isCancel(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "cancel";
  }
  public static function isEndWait(owner:SeqMgr):Bool {
    return owner.isEndWait();
  }
  public static function isWin(owner:SeqMgr):Bool {
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
}

// -----------------------------------------------------------
// -----------------------------------------------------------
private class Boot extends FlxFSMState<SeqMgr> {
}
// フィールド
private class DgMain extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();
    // UIを表示
    BattleUI.setVisibleGroup("field", true);
    // 休憩ボタンチェック
    if(owner.player.food <= 0) {
      // 押せない
      BattleUI.lockButton("field", "rest");
    }
    // 次のフロアに進めるかどうか
    if(owner.isFoundStair() == false) {
      BattleUI.lockButton("field", "nextfloor");
    }
  }

  override public function exit(owner:SeqMgr):Void {
    // UIを非表示
    BattleUI.setVisibleGroup("field", false);
  }

}
// フィールド - 探索中……
private class DgSearch extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // 歩数を増やす
    Global.addStep();

    Message.push2(Msg.SEARCHING);

    var player = owner.player;

    // 食糧を減らす
    if(player.subFood(1) == false) {
      // 空腹ダメージ
      // 残りHPの30%ダメージ
      var hp = player.hp;
      var v = Std.int(hp * 0.3);
      if(v < 3) {
        v = 3;
      }
      player.damage(v);
    }
    else {
      // 10%回復
      var hpmax = player.hpmax;
      var v = Std.int(hpmax * 0.1);
      player.recover(v);
    }

    owner.startWait();
  }
}

// フィールド - 探索実行
private class DgSearch2 extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // イベントを抽選する
    owner.checkFieldEvent();
  }
}

// フィールド - アイテム獲得
private class DgGain extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // アイテムを抽選
    var itemid = ItemGain.lotItem(Global.level);
    var item = ItemUtil.add(itemid);
    var name = ItemUtil.getName(item);
    if(ItemList.isFull()) {
      Message.push2(Msg.ITEM_FIND, [name]);
      Message.push2(Msg.ITEM_CANT_GET);
    }
    else {
      // アイテムを手に入れた
      ItemList.push(item);
      Message.push2(Msg.ITEM_GET, [name]);
    }

    owner.startWait();
  }
}

// フィールド - 休憩
private class DgRest extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.REST);
    // HP回復 (30%回復)
    var player = owner.player;
    var v = Std.int(player.hpmax * 0.3);
    player.recover(v);
    Message.push2(Msg.RECOVER_HP, [player.getName(), v]);
    // 食糧を減らす
    player.subFood(1);

    owner.startWait();
  }
}
// フィールド - アイテム捨てる
private class DgDrop extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();
    // インベントリ表示
    BattleUI.showInventory(InventoryMode.ItemDrop);
  }
  override public function exit(owner:SeqMgr):Void {
    // インベントリ非表示
    BattleUI.setVisibleGroup("inventory", false);
  }
}
// フィールド - アイテム捨てる(実行)
private class DgDrop2 extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var item = owner.getSelectedItem();
    var name = ItemUtil.getName(item);
    Message.push2(Msg.ITEM_DEL, [name]);
    ItemList.del(item.uid);
    // 食糧が増える
    var v = item.max - item.now + 1;
    owner.player.addFood(v);
    Message.push2(Msg.FOOD_ADD, [v]);
    owner.startWait();
  }
}
// フィールド - 次のフロアに進む
private class DgNextFloor extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}
// 敵出現
private class EnemyAppear extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 敵UI表示
    BattleUI.setVisibleGroup("enemyhud", true);
    // 敵出現
    var e = new Params();
    // TODO:
    e.id = 1;
    owner.enemy.init(e);
    Message.push2(Msg.ENEMY_APPEAR, [owner.enemy.getName()]);
    // 背景を暗くする
    Bg.darken();
    owner.startWait();
  }
}

// キー入力待ち
private class CommandInput extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();
    // インベントリ表示
    BattleUI.showInventory(InventoryMode.Battle);
  }

  override public function exit(owner:SeqMgr):Void {
    // インベントリ非表示
    BattleUI.setVisibleGroup("inventory", false);
  }
}

// プレイヤー行動開始
private class PlayerBegin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var item = owner.getSelectedItem();
    var name = ItemUtil.getName2(item);
    Message.push2(Msg.ITEM_USE, [owner.player.getName(), name]);
    owner.startWait();
  }
}

// プレイヤー行動実行
private class PlayerAction extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // ダメージ計算
    var item = owner.getSelectedItem();
    var damage:Int = 0; // ダメージ量
    if(ItemUtil.isComsumable(item)) {
      // 回復アイテム
    }
    else {
      // 装備品
      damage = ItemUtil.calcDamage(item);
      // 命中判定
      var hit = ItemUtil.getHit(item);
      if(FlxG.random.bool(hit) == false) {
        // 回避
        damage = -1;
      }
    }

    // TODO: 攻撃回避判定
    owner.enemy.damage(damage);

    // アイテム使用回数減少
    item.now -= 1;
    if(item.now <= 0) {
      // アイテム壊れる
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_DESTROY, [name]);
      ItemList.del(item.uid);
    }
    owner.startWait();
  }
}

// 敵の行動開始
private class EnemyBegin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ATTACK_BEGIN, [owner.enemy.getName()]);
    owner.startWait();
  }
}

// 敵の行動実行
private class EnemyAction extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var enemy = owner.enemy;
    var v = enemy.str;
    // 命中判定
    var hit = EnemyInfo.getHit(enemy.id);
    if(FlxG.random.bool(hit) == false) {
      // 回避
      v = -1;
    }
    owner.player.damage(v);
    owner.startWait();
  }
}

// ターン終了
private class TurnEnd extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 食糧を減らす
    owner.player.subFood(1);
  }
}

// 勝利
private class Win extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    var enemy = owner.enemy;

    // 勝利メッセージ表示
    Message.push2(Msg.DEFEAT_ENEMY, [enemy.getName()]);

    owner.startWait();
  }
}
// 敗北
private class Lose extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.DEAD, [owner.player.getName()]);
    owner.startWait();
  }
}
// 逃走
private class Escape extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ESCAPE, [owner.player.getName()]);
    owner.startWait();
  }
}
// アイテム獲得
private class ItemGet extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    var enemy = owner.enemy;
    // アイテム獲得
    var dropitems = EnemyInfo.getDropItems(enemy.id);
    FlxG.random.shuffleArray(dropitems, 3);
    var itemid = dropitems[0];
    var item = ItemUtil.add(itemid);
    var name = ItemUtil.getName(item);
    Message.push2(Msg.ITEM_DROP, [enemy.getName(), name]);
    if(ItemList.isFull()) {
      Message.push2(Msg.ITEM_CANT_GET);
    }
    else {
      // アイテムを手に入れた
      ItemList.push(item);
      Message.push2(Msg.ITEM_GET, [name]);
    }

    owner.startWait();
  }
}
// 戦闘終了
private class BtlEnd extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 背景を明るくする
    Bg.brighten();
    // 敵を消す
    owner.enemy.visible = false;
    // 敵UIを消す
    BattleUI.setVisibleGroup("enemyhud", false);
  }
}
