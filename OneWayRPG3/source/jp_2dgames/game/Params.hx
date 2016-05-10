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
  public var dex:Int   = 0;  // 器用さ
  public var agi:Int   = 0;  // 素早さ

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  /**
   * 初期化
   **/
  public function clear():Void {
    hp    = 0;
    hpmax = 0;
    food  = 0;
    str   = 0;
    vit   = 0;
    dex   = 0;
    agi   = 0;
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
    dex   = src.dex;
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
