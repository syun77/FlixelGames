package jp_2dgames.game.actor;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var hp:Int;

  public function new() {
    hp = 1;
  }

  public function copyFromDynamic(p):Void {
    hp = p.hp;
  }
}
