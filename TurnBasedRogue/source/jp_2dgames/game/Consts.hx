package jp_2dgames.game;

/**
 * ゲームパラメータ定義
 **/
class Consts {

  // 次のフロアに進むときに回復するターン数
  public static inline var RECOVER_NEXT_FLOOR:Int = 10;

  // 敵を倒したときに回復するターン数
  public static inline var RECOVER_ENEMY_KILL:Int = 0;

  // ヒール使用時に回復するターン数
  public static inline var RECOVER_HEAL:Int = 1;

  // ハート獲得時に回復するターン数
  public static inline var RECOVER_HEART:Int = 10;

  // 死亡時のペナルティとなるターン数
  public static inline var DAMAGE_DEAD:Int = 5;
}
