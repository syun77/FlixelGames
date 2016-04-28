package jp_2dgames.game;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:Int    = 0;
  public var hp:Int    = 100;
  public var hpmax:Int = 100;
  public var str:Int   = 10;
  public var vit:Int   = 5;
  public var agi:Int   = 5;

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
    str   = src.str;
    vit   = src.vit;
    agi   = src.agi;
  }
}
