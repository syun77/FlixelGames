package jp_2dgames.game;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:Int    = 0;   // ID
  public var hp:Int    = 100; // HP
  public var hpmax:Int = 100; // 最大HP
  public var food:Int  = 10;  // 食糧
  public var str:Int   = 10;  // 力
  public var vit:Int   = 5;   // 体力
  public var agi:Int   = 5;   // 素早さ

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  /**
   * コピー
   **/
  public function copy(src:Params):Void {
    id    = src.id;
    hp    = src.hp;
    hpmax = src.hpmax;
    food  = src.food;
    str   = src.str;
    vit   = src.vit;
    agi   = src.agi;
  }
}
