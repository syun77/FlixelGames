package jp_2dgames.game.sequence;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.gui.BattleUI;
import flixel.addons.util.FlxFSM;

// ダンジョン入力待ち
class Dg extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();
    // UIを表示
    BattleUI.setVisibleGroup("field", true);
  }

  override public function exit(owner:SeqMgr):Void {
    // UIを非表示
    BattleUI.setVisibleGroup("field", false);
  }

}

// ダンジョン - 休憩
class DgRest extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.REST);
    // HP回復 (30%回復)
    var player = owner.player;
    var v = Std.int(player.hpmax * 0.3);
    player.recover(v);
    Message.push2(Msg.RECOVER_HP, [player.getName(), v]);
    //Snd.playSe("recover");
    // 食糧を減らす
    player.subFood(1);

    owner.startWait();

  }
}

// ダンジョン - アイテム捨てる
class DgDrop extends FlxFSMState<SeqMgr> {
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

// ダンジョン - アイテム捨てる(実行)
class DgDrop2 extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var item = owner.getSelectedItem();
    var name = ItemUtil.getName(item);
    Message.push2(Msg.ITEM_DEL, [name]);
    ItemList.del(item.uid);
    // 食糧が増える
    var v = item.now;
    owner.player.addFood(v);
    Message.push2(Msg.FOOD_ADD, [v]);
    owner.startWait();
  }
}
