package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.sequence.btl.BtlCalc;
import jp_2dgames.game.dat.AttributeUtil.Attribute;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.sequence.btl.BtlLogic;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;

/**
 * BtlLogicDataの生成
 **/
class BtlLogicFactory {

  /**
   * 行動種別を取得 (プレイヤー)
   **/
  static function _getActionTypePlayer(owner:SeqMgr, item:ItemData):BtlLogic {

    var player = owner.player;
    var enemy = owner.enemy;
    if(ItemList.isEmpty()) {
      // 自動攻撃
      var type = BtlLogicAttack.Normal;
      // 1回攻撃・命中率100%・物理
      var count = 1;
      var ratioRaw = 100;
      var ratio = BtlCalc.hit(ratioRaw, player, enemy);
      var attr  = Attribute.Phys;
      var prm = new BtlLogicAttackParam(count, ratio, ratioRaw, attr);
      return BtlLogic.Attack(type, prm);
    }

    if(item == null) {
      item = owner.getSelectedItem();
    }
    switch(ItemUtil.getCategory(item)) {
      case ItemCategory.Portion:
        // 回復
        var hp = ItemUtil.getHp(item);
        var prm = new BtlLogicRecoverParam(hp);
        return BtlLogic.Recover(prm);

      case ItemCategory.Weapon:
        // 武器
        var power = ItemUtil.getPower(item);
        if(item.now == 1) {
          // 最後の一撃
          power *= 3;
        }
        var ratioRaw = ItemUtil.getHit(item);
        var ratio = BtlCalc.hit(ratioRaw, player, enemy);
        var count = ItemUtil.getCount(item);
        var attr  = ItemUtil.getAttribute(item);
        var prm = new BtlLogicAttackParam(power, ratio, ratioRaw, attr);
        var type = BtlLogicAttack.Normal;
        if(count > 1) {
          // 複数回攻撃
          type = BtlLogicAttack.Multi;
        }
        return BtlLogic.Attack(type, prm);
    }
  }


  /**
   * 行動回数を計算
   **/
  static function _getActionCount(owner:SeqMgr, group:BtlGroup, item:ItemData):Int {
    switch(group) {
      case BtlGroup.Both:
        return 1;

      case BtlGroup.Player:
        if(ItemList.isEmpty()) {
          // 自動攻撃
          return 1;
        }

        if(item == null) {
          item = owner.getSelectedItem();
        }
        return ItemUtil.getCount(item);

      case BtlGroup.Enemy:
        return 1;
    }
  }

  /**
   * プレイヤーのBtlLogicDataを生成
   **/
  public static function createPlayerLogic(owner:SeqMgr, item:ItemData):BtlLogicData {
    var type  = _getActionTypePlayer(owner, item);
    var count = _getActionCount(owner, BtlGroup.Player, item);

    var actor  = owner.player;
    var target = owner.enemy;
    switch(type) {
      case BtlLogic.None:

      case BtlLogic.Attack:

      case BtlLogic.Recover:
        // プレイヤーが回復対象
        target = owner.player;
    }
    return new BtlLogicData(type, count, actor, target);
  }

  /**
   * 敵のBtlLogicDataを生成
   **/
  public static function createEnemyLogic(owner:SeqMgr):BtlLogicData {

    var func = function() {
      var enemy = owner.enemy;
      var type = BtlLogicAttack.Normal;
      var power = enemy.str;
      var ratioRaw = EnemyDB.getHit(enemy.id);
      var ratio = BtlCalc.hit(ratioRaw, enemy, owner.player);
      var attr  = Attribute.Phys;
      var prm  = new BtlLogicAttackParam(power, ratio, ratioRaw, attr);
      return BtlLogic.Attack(type, prm);
    }
    var type = func();
    var count = 1;

    var actor  = owner.enemy;
    var target = owner.player;

    return new BtlLogicData(type, count, actor, target);
  }
}
