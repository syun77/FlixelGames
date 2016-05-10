package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.sequence.btl.BtlLogic;
import flixel.FlxG;
import jp_2dgames.game.actor.Actor;

/**
 * バトルの数値計算
 **/
class BtlCalc {

  // 回避時のダメージ量
  public static inline var VAL_AVOID:Int = -1;

  // 回避率補正値
  public static inline var VAL_DEX:Int = 2;
  public static inline var VAL_AGI:Int = 2;

  public static function hit(ratio:Int, actor:Actor, target:Actor):Int {

    // DEX / AGI の値に応じて2%ずつ補正
    ratio += (actor.dex * VAL_DEX);
    ratio -= (target.agi * VAL_AGI);
    if(ratio < 0) {
      ratio = 0;
    }

    return ratio;
  }

  /**
   * 命中確率の取得
   **/
  public static function hitFromParam(prm:BtlLogicAttackParam, actor:Actor, target:Actor):Int {

    // 補正値なしの命中率を取得
    var ratio:Int = prm.ratioRaw;

    return hit(ratio, actor, target);
  }

  /**
   * 攻撃命中判定
   **/
  public static function isHit(prm:BtlLogicAttackParam, actor:Actor, target:Actor):Bool {
    var hit = hitFromParam(prm, actor, target);
    return FlxG.random.bool(hit);
  }

  /**
   * ダメージ量計算
   **/
  public static function damage(prm:BtlLogicAttackParam, actor:Actor, target:Actor):Int {

    var power = prm.power;
    // ダメージ量
    var damage = power;
    // 属性ボーナス
    var resisits = EnemyDB.getResists(target.id);
    var value = resisits.getValue(prm.attr);
    damage = Math.ceil(damage * value);

    return damage;
  }
}

