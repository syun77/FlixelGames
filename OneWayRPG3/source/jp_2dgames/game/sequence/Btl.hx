package jp_2dgames.game.sequence;
import jp_2dgames.game.state.InventorySubState;
import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.game.SeqMgr.SeqItemFull;
import jp_2dgames.game.dat.ItemLotteryDB;
import jp_2dgames.game.dat.FloorInfoDB;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.sequence.btl.BtlLogicPlayer;
import jp_2dgames.game.sequence.btl.BtlLogicFactory;
import jp_2dgames.game.sequence.btl.BtlLogicData;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.item.ItemList;
import flixel.FlxG;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.dat.EnemyEncountDB;
import jp_2dgames.game.global.Global;
import flixel.addons.util.FlxFSM;

/**
 * 行動タイプ
 **/
private enum ActionType {
  None;    // 何もしない
  Attack;  // 攻撃
  Recover; // 回復
}

/**
 * バトル開始
 **/
class BtlBoot extends FlxFSMState<SeqMgr> {

  /**
   * 属性アイコンの表示
   **/
  function _displayEnemyAttribute(enemy:Actor):Void {
    // 属性アイコン表示
    var setVisible = function(idx:Int, b:Bool) {
      BattleUI.setVisibleItem("enemyhud", BattleUI.getResistIconName(idx), b);
      BattleUI.setVisibleItem("enemyhud", BattleUI.getResistTextName(idx), b);
    }
    var setIcon = function(idx:Int, path:String) {
      BattleUI.setSpriteItem("enemyhud", BattleUI.getResistIconName(idx), path);
    }
    var setText = function(idx:Int, ratio:Float) {
      BattleUI.setTextItem("enemyhud", BattleUI.getResistTextName(idx), 'x ${ratio}');
    }

    // いったん非表示
    for(i in 0...2) {
      setVisible(i, false);
    }

    // 設定されている属性を表示
    var idx:Int = 0;
    var resists = EnemyDB.getResists(enemy.id);
    for(resist in resists.list) {
      // 表示
      setVisible(idx, true);
      // アイコン変更
      var path = AttributeUtil.getIconPath(resist.attr);
      setIcon(idx, path);
      // 倍率設定
      setText(idx, resist.value);
      idx++;
    }
  }

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 敵UI表示
    BattleUI.setVisibleGroup("enemyhud", true);
    // 敵出現
    var e = new Params();
    if(Global.step >= 1) {
      // 通常の敵
      e.id = EnemyEncountDB.lottery(Global.level);
    }
    else {
      // ボス
      e.id = FloorInfoDB.getBoss(Global.level);
    }
    owner.enemy.init(e);
    Message.push2(Msg.ENEMY_APPEAR, [owner.enemy.getName()]);
    // 背景を暗くする
    Bg.darken();
    // 属性アイコンの表示
    _displayEnemyAttribute(owner.enemy);

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

    if(ItemList.isEmpty() == false) {
      // インベントリ表示
      FlxG.state.openSubState(new InventorySubState(owner, InventoryMode.Battle));
    }
  }
}

/**
 * プレイヤー行動開始
 **/
class BtlPlayerBegin extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    if(ItemList.isEmpty()) {
      // 自動攻撃
      Message.push2(Msg.AUTO_ATTACK);
    }
    else {
      // アイテムを使った
      var item = owner.getSelectedItem();
      var name = ItemUtil.getName2(item);
      Message.push2(Msg.ITEM_USE, [owner.player.getName(), name]);
    }
    owner.startWait();
  }
}

/**
 * プレイヤー行動メイン
 **/
class BtlPlayerMain extends FlxFSMState<SeqMgr> {

  /**
   * アイテム使用回数の低下
   **/
  function _degrationItem(owner:SeqMgr):Void {

    if(ItemList.isEmpty()) {
      // 自動攻撃
      return;
    }

    var item = owner.getSelectedItem();
    item.now -= 1;
    if(item.now <= 0) {
      // アイテム壊れる
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_DESTROY, [name]);
      ItemList.del(item.uid);
    }
  }

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // 演出データを生成
    var logic = BtlLogicFactory.createPlayerLogic(owner, null);
    // 登録
    BtlLogicPlayer.init(logic);
  }

  override public function update(elapsed:Float, owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // 演出更新
    BtlLogicPlayer.proc(elapsed, owner);
  }

  override public function exit(owner:SeqMgr):Void {
    // アイテム使用回数減少
    _degrationItem(owner);
  }
}

/**
 * 敵の行動開始
 **/
class BtlEnemyBegin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ATTACK_BEGIN, [owner.enemy.getName()]);
    owner.startWait();
  }
}

/**
 * 敵の行動メイン
 **/
class BtlEnemyMain extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // 演出データを生成
    var logic = BtlLogicFactory.createEnemyLogic(owner);
    // 登録
    BtlLogicPlayer.init(logic);
  }

  override public function update(elapsed:Float, owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 演出更新
    BtlLogicPlayer.proc(elapsed, owner);
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
 * 敵死亡
 **/
class BtlEnemyDead extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var enemy = owner.enemy;
    enemy.vanish();

    //owner.startWait();
  }
}

/**
 * アイテム強化
 **/
class BtlPowerup extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    if(owner.enemy.hp != 0) {
      return;
    }

    // ジャストボーナス
    Message.push2(Msg.JUST_ZERO_BONUS);

    var item = owner.getSelectedItem();
    if(item != null) {
      // アイテム強化
      switch(ItemUtil.getCategory(item)) {
        case ItemCategory.Weapon:
          // 敵を倒した武器を強化
          item.buff++;
          var name = ItemUtil.getName2(item);
          Message.push2(Msg.WEAPON_POWERUP, [name]);
          Snd.playSe("powerup");
          owner.startWait();

        case ItemCategory.Portion:
      }
    }

  }
}

/**
 * 勝利
 **/
class BtlWin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var enemy = owner.enemy;

    // 勝利メッセージ表示
    Message.push2(Msg.DEFEAT_ENEMY, [enemy.getName()]);

    owner.startWait();
  }
}

/**
 * アイテム獲得
 **/
class BtlItemGet extends FlxFSMState<SeqMgr> {
 override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
   var enemy = owner.enemy;
   // 30%の確率でアイテムドロップ
   var rnd:Int = 30;
   if(enemy.hp == 0) {
     // ジャストボーナス
     rnd = 100;
   }
   if(FlxG.random.bool(rnd)) {
     // アイテム獲得
     var item = ItemLottery.exec();
     var name = ItemUtil.getName(item);
     if(ItemList.isFull()) {
       // アイテムを取得できない
       Message.push2(Msg.ITEM_FIND, [name]);
       Message.push2(Msg.ITEM_CANT_GET);
     }
     else {
       // アイテムを手に入れた
       ItemList.push(item);
       Message.push2(Msg.ITEM_GET, [name]);
       // 消しておく
       ItemLottery.clearLastLottery();
     }
   }
 }
}

/**
 * アイテムが一杯のメニュー
 **/
class BtlItemFull extends SeqItemFull {
}

/**
 * 逃走
 **/
class BtlEscape extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ESCAPE, [owner.player.getName()]);
    owner.startWait();
  }
}

/**
 * 敗北
 **/
class BtlLose extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.DEAD, [owner.player.getName()]);
    owner.startWait();
  }
}

/**
 * バトル終了
 **/
class BtlEnd extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 背景を明るくする
    Bg.brighten();
    // 敵を消す
    owner.enemy.visible = false;
    // 敵UIを消す
    BattleUI.setVisibleGroup("enemyhud", false);
  }
}

