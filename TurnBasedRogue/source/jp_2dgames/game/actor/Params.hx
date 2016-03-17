package jp_2dgames.game.actor;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:Int;
  public var hp:Int;

  public function new() {
    id = 0;
    hp = 3;
  }

  public function copyFromDynamic(p):Void {
    id = p.id;
    hp = p.hp;
  }
}
