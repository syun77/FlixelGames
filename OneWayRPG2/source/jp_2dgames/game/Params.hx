package jp_2dgames.game;

import jp_2dgames.game.dat.MyDB;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:EnemiesKind; // ID
  public var hp:Int    = 10; // HP
  public var hpmax:Int = 10; // 最大HP
  public var food:Int  = 10; // 食糧
  public var str:Int   = 0;  // 力
  public var vit:Int   = 0;  // 体力
  public var agi:Int   = 0;  // 素早さ

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

  /**
   * 最大HPを設定する
   **/
  public function setHpMax(v:Int):Void {
    hpmax = v;
    hp = v;
  }
}
