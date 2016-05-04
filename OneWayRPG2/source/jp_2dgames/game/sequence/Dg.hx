package jp_2dgames.game.sequence;
import jp_2dgames.game.dat.ItemLotteryDB;
import jp_2dgames.game.sequence.DgEventMgr.DgEvent;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.gui.BattleUI;
import flixel.addons.util.FlxFSM;

/**
 * ダンジョン入力待ち
 **/
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

/**
 * ダンジョン - 探索
 **/
class DgSearch extends FlxFSMState<SeqMgr> {
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

/**
 * ダンジョン - 探索実行
 **/
class DgSearch2 extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // イベントを抽選する
    DgEventMgr.lottery();
  }
}

/**
 * ダンジョン - 休憩
 **/
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

/**
 * ダンジョン - アイテム捨てる
 **/
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

/**
 * ダンジョン - アイテム捨てる(実行)
 **/
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

/**
 * ダンジョン - アイテム獲得
 */
class DgGain extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // アイテムを抽選
    var itemid = ItemLotteryDB.lottery(Global.level);
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