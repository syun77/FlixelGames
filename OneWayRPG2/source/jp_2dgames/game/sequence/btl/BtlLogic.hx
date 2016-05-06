package jp_2dgames.game.sequence.btl;

enum BtlLogicAttack {
  Normal; // 通常
  Multi;  // 複数回攻撃
}

/**
 * 攻撃行動のパラメータ
 **/
class BtlLogicAttackParam {
  public var power:Int; // ダメージ量
  public var ratio:Int; // 命中率

  /**
   * コンストラクタ
   **/
  public function new(power:Int, ratio:Int) {
    this.power = power;
    this.ratio = ratio;
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
