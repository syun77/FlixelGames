package jp_2dgames.game.sequence;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.dat.EnemyEncountDB;
import jp_2dgames.game.global.Global;
import flixel.addons.util.FlxFSM;

/**
 * バトル開始
 **/
class BtlBoot extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 敵UI表示
    BattleUI.setVisibleGroup("enemyhud", true);
    // 敵出現
    var e = new Params();
    e.id = EnemyEncountDB.lottery(Global.level);
    owner.enemy.init(e);
    Message.push2(Msg.ENEMY_APPEAR, [owner.enemy.getName()]);
    // 背景を暗くする
    Bg.darken();
    owner.startWait();
  }
}

/**
 * バトル入力待ち
**/
class Btl extends FlxFSMState<SeqMgr> {
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

/**
 * プレイヤー行動開始
 **/
class BtlPlayerBegin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * プレイヤー行動メイン
 **/
class BtlPlayerMain extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * 敵の行動開始
 **/
class BtlEnemyBegin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * 敵の行動メイン
 **/
class BtlEnemyMain extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * ターン終了
 **/
class BtlTurnEnd extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * 勝利
 **/
class BtlWin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * アイテム獲得
 **/
class BtlItemGet extends FlxFSMState<SeqMgr> {
 override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
 }
}

/**
 * 逃走
 **/
class BtlEscape extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * 敗北
 **/
class BtlLose extends FlxFSMState<SeqMgr> {
}

/**
 * バトル終了
 **/
class BtlEnd extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

