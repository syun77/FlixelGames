package jp_2dgames.game;

import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
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
      .add(Boot,         FieldMain,    Conditions.isEndWait)    // 開始        -> フィールド
      // フィールド
      .add(FieldMain,    FieldSearch,  Conditions.isSearch)     // フィールド   -> 探索
      .add(FieldMain,    FieldRest,    Conditions.isRest)       // フィールド   -> 休憩
      .add(FieldMain,    FieldNextFloor, Conditions.isNextFloor)// フィールド   -> 次のフロアへ
      // フィールド - 探索
      .add(FieldSearch,  EnemyAppear,  Conditions.isAppearEnemy)// 探索        -> 敵出現
      .add(FieldSearch,  Lose,         Conditions.isDead)       // 探索        -> 死亡
      .add(FieldSearch,  FieldMain,    Conditions.isEndWait)    // 探索        -> フィールドに戻る
      // フィールド - 休憩
      .add(FieldRest,    FieldMain,    Conditions.isEndWait)    // 休憩        -> フィールド
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
      .add(EnemyAction,  CommandInput, Conditions.isEndWait)
      // 勝利
      .add(Win,          FieldMain,    Conditions.isEndWait)    // 勝利          -> フィールドに戻る
      // 逃走
      .add(Escape,       FieldMain,    Conditions.isEndWait)    // 逃走          -> フィールドに戻る
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
    rnd = 0;
    if(rnd < 50) {
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
    else {
      // 何も起きない
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
      var detail = ItemUtil.getDetail(item);
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
      case FieldNextFloor:
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
  public static function isNextFloor(owner:SeqMgr):Bool {
    return owner.getLastClickButton() == "nextfloor";
  }
  public static function isAppearEnemy(owner:SeqMgr):Bool {
    // 敵に遭遇したかどうか
    return owner.event == FieldEvent.Encount;
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
private class FieldMain extends FlxFSMState<SeqMgr> {
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
// フィールド - 探索
private class FieldSearch extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // イベントを抽選する
    owner.checkFieldEvent();
    // 食糧を減らす
    if(owner.player.subFood(1) == false) {
      // 空腹ダメージ
      var hp = owner.player.hp;
      // 残りHPの30%ダメージ
      var v = Std.int(hp * 0.3);
      if(v < 3) {
        v = 3;
      }
      owner.player.damage(v);
    }

    owner.startWait();
  }
}
// フィールド - 休憩
private class FieldRest extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // TODO: HP回復
    owner.player.recover(30);
    // 食糧を減らす
    owner.player.subFood(1);

    owner.startWait();
  }
}
// フィールド - 次のフロアに進む
private class FieldNextFloor extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}
// 敵出現
private class EnemyAppear extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
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
    BattleUI.setVisibleGroup("inventory", true);
    for(i in 0...ItemList.MAX) {
      var item = ItemList.getFromIdx(i);
      var key = 'item${i}';
      if(item == null) {
        // 所持していないので非表示
        BattleUI.setVisibleItem("inventory", key, false);
        continue;
      }
      // 表示する
      BattleUI.setVisibleItem("inventory", key, true);
      var name = ItemUtil.getName(item);
      BattleUI.setButtonLabel("inventory", key, name);
    }
    // 詳細テキスト非表示
    BattleUI.setDetailText("");
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
    var power = ItemUtil.getPower(owner.getSelectedItem());
    var v = power;
    owner.enemy.damage(v);
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
    var v = FlxG.random.int(30, 40);
    owner.player.damage(v);
    owner.startWait();
  }
}

// 勝利
private class Win extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 背景を明るくする
    Bg.brighten();
    Message.push2(Msg.DEFEAT_ENEMY, [owner.enemy.getName()]);
  }
}
// 敗北
private class Lose extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.DEAD, [owner.player.getName()]);
  }
}
// 逃走
private class Escape extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ESCAPE, [owner.player.getName()]);
    // 背景を明るくする
    Bg.brighten();
    // 敵を消す
    owner.enemy.visible = false;
  }
}