package jp_2dgames.game.sequence;
import jp_2dgames.game.gui.BattleUI;
import flixel.addons.util.FlxFSM;

// ダンジョン入力待ち
class Dg extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // UIを表示
    BattleUI.setVisibleGroup("field", true);
  }
}
