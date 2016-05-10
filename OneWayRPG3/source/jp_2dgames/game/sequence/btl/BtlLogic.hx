package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.dat.AttributeUtil.Attribute;
enum BtlLogicAttack {
  Normal; // 通常
  Multi;  // 複数回攻撃
}

/**
 * 攻撃行動のパラメータ
 **/
class BtlLogicAttackParam {
  public var power:Int;      // ダメージ量
  public var ratio:Int;      // 命中率
  public var ratioRaw:Int;   // 主体者・対象者による補正がな状態の命中率
  public var attr:Attribute; // 属性

  /**
   * コンストラクタ
   **/
  public function new(power:Int, ratio:Int, ratioRaw:Int, attr:Attribute) {
    this.power = power;
    this.ratio = ratio;
    this.ratioRaw = ratioRaw;
    this.attr  = attr;
  }
}

/**
 * 回復行動のパラメータ
 **/
class BtlLogicRecoverParam {
  public var hp:Int; // HP回復量

  /**
   * コンストラクタ
   **/
  public function new(hp:Int) {
    this.hp = hp;
  }
}

/**
 * バトル行動タイプ
 **/
enum BtlLogic {
  None; // 何もしない
  Attack(type:BtlLogicAttack, prm:BtlLogicAttackParam); // 攻撃
  Recover(prm:BtlLogicRecoverParam); // 回復
}
