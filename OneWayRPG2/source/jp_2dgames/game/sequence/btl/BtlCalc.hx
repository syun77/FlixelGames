package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.sequence.btl.BtlLogic.BtlLogicAttackParam;
import flixel.FlxG;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.actor.Actor;

/**
 * バトルの数値計算
 **/
class BtlCalc {

  // 回避時のダメージ量
  static inline var VAL_AVOID:Int = -1;

  public static function damage(owner:SeqMgr, prm:BtlLogicAttackParam, actor:Actor, target:Actor):Int {

    if(ItemList.isEmpty()) {
      // 自動攻撃
      return 1;
    }

    var str = actor.str;
    var power = prm.power;
    // ダメージ量
    var damage = str + power;
    // 属性ボーナス
    var resisits = EnemyDB.getResists(target.id);
    var value = resisits.getValue(prm.attr);
    damage = Math.ceil(damage * value);
    // 命中判定
    var hit = prm.ratio;
    if(FlxG.random.bool(hit) == false) {
      // 回避
      damage = VAL_AVOID;
    }

    return damage;
  }
}

