package jp_2dgames.game.sequence;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.item.ItemList;
import flixel.FlxG;
import jp_2dgames.game.item.ItemUtil;
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
   * ダメージ量計算
   **/
  function _calcDamage(owner:SeqMgr):Int {

    if(ItemList.isEmpty()) {
      // 自動攻撃
      return 1;
    }

    var item = owner.getSelectedItem();
    var damage:Int = 0; // ダメージ量
    switch(ItemUtil.getCategory(item)) {
      case ItemCategory.Portion:
        // 回復アイテム

      case ItemCategory.Weapon:
        // 武器
        damage = ItemUtil.calcDamage(item);
        // 命中判定
        var hit = ItemUtil.getHit(item);
        if(FlxG.random.bool(hit) == false) {
          // 回避
          damage = -1;
        }
    }

    return damage;
  }

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
    // ダメージ計算
    var damage = _calcDamage(owner);
    owner.enemy.damage(damage);

    // アイテム使用回数減少
    _degrationItem(owner);
    owner.startWait();
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
    var enemy = owner.enemy;
    var v = enemy.str;
    // 命中判定
    var hit = EnemyDB.getHit(enemy.id);
    if(FlxG.random.bool(hit) == false) {
      // 回避
      v = -1;
    }
    owner.player.damage(v);
    owner.startWait();
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
     var itemid = EnemyDB.lotteryDropItem(enemy.id);
     if(ItemUtil.isNone(itemid) == false) {
       var item = ItemUtil.add(itemid);
       var name = ItemUtil.getName(item);
       Message.push2(Msg.ITEM_DROP, [enemy.getName(), name]);
       if(ItemList.isFull()) {
         //Snd.playSe("error");
         Message.push2(Msg.ITEM_CANT_GET);
       }
       else {
         // アイテムを手に入れた
         ItemList.push(item);
         Message.push2(Msg.ITEM_GET, [name]);
       }
     }

     owner.startWait();
   }
 }
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

