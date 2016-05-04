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
}
