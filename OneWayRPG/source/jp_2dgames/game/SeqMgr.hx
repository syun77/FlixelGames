package jp_2dgames.game;

import lime.tools.helpers.StringHelper;
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
 * シーケンス管理
 **/
class SeqMgr extends FlxBasic {

  public static inline var RET_NONE:Int    = 0;
  public static inline var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static inline var RET_STAGECLEAR:Int  = 5; // ステージクリア

  static inline var TIMER_WAIT:Int = 30;

  var _tWait:Int = 0;
  var _bDead:Bool = false;
  var _bStageClear:Bool = false;

  var _fsm:FlxFSM<SeqMgr>;
  var _fsmName:String;

  var _bPressAttack:Bool = false;
  var _lastClickButton:String = "";

  var _player:Actor;
  var _enemy:Actor;

  public var player(get, never):Actor;
  public var enemy(get, never):Actor;

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
      // フィールド
      .add(MyField,      FieldSearch,  Conditions.isSearch)    // フィールド    -> 探索
      .add(MyField,      FieldRest,    Conditions.isRest)      // フィールド    -> 休憩
      .add(MyField,      FieldNextFloor, Conditions.isNextFloor)// フィールド   -> 次のフロアへ
      // フィールド - 探索
      .add(FieldSearch,  EnemyAppear,  Conditions.isAppearEnemy)// 探索        -> 敵出現

      // バトル開始
      .add(EnemyAppear,  CommandInput, Conditions.isEndWait)   // 敵出現        -> キー入力
      .add(CommandInput, PlayerBegin,  Conditions.isReadyCommand) // コマンド入力-> プレイヤー行動
      // プレイヤー行動
      .add(PlayerBegin,  PlayerAction, Conditions.isEndWait)   // プレイヤー開始 -> プレイヤー実行
      .add(PlayerAction, Win,          Conditions.isWin)       // 勝利判定
      .add(PlayerAction, EnemyBegin,   Conditions.isEndWait)
      // 敵の行動
      .add(EnemyBegin,   EnemyAction,  Conditions.isEndWait)
      .add(EnemyAction,  Lose,         Conditions.isLose)      // 敗北判定
      .add(EnemyAction,  CommandInput, Conditions.isEndWait)
      // 勝利
      .add(Win,          MyField,      Conditions.keyInput)    // 勝利          -> フィールドに戻る
      .start(MyField);
    _fsm.stateClass = MyField;
    _fsmName = Type.getClassName(_fsm.stateClass);
    FlxG.watch.add(this, "_fsmName", "fsm");
    FlxG.watch.add(this, "_lastClickButton", "button");
    FlxG.watch.add(this, "_tWait", "tWait");

    // ボタンのコールバックを設定
    BattleUI.setButtonCB("attack", _pressAttack);
    BattleUI.setButtonClickCB(_cbButtonClick);
  }

  function _cbButtonClick(name:String):Void {
    _lastClickButton = name;
  }
  public function resetLastClickButton():Void {
    _lastClickButton = "";
  }

  function _pressAttack():Void {
    _bPressAttack = true;
  }
  public function resetPressAttack():Void {
    _bPressAttack = false;
  }
  public function isPressAttack():Bool {
    return _bPressAttack;
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
        return RET_DEAD;
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

  // ------------------------------------------------------
  // ■アクセサ
  function get_player() {
    return _player;
  }
  function get_enemy() {
    return _enemy;
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
    return true;
  }
  public static function keyInput(owner:SeqMgr):Bool {
    return Input.press.A;
  }
  public static function isReadyCommand(owner:SeqMgr):Bool {
    return owner.isPressAttack();
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
  public static function isLose(owner:SeqMgr):Bool {
    if(isEndWait(owner) == false) {
      return false;
    }
    return owner.player.isDead();
  }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
// フィールド
private class MyField extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    owner.resetLastClickButton();
  }
}
// フィールド - 探索
private class FieldSearch extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}
// フィールド - 休憩
private class FieldRest extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
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
    owner.startWait();
  }
}

// キー入力待ち
private class CommandInput extends FlxFSMState<SeqMgr> {
  override public function exit(owner:SeqMgr):Void {
    owner.resetPressAttack();
  }
}

// プレイヤー行動開始
private class PlayerBegin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ATTACK_BEGIN, [owner.player.getName()]);
    owner.startWait();
  }
}

// プレイヤー行動実行
private class PlayerAction extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var v = FlxG.random.int(30, 40);
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
    Message.push2(Msg.DEFEAT_ENEMY, [owner.enemy.getName()]);
  }
}
// 敗北
private class Lose extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.DEAD, [owner.player.getName()]);
  }
}