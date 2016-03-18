package jp_2dgames.game.actor;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:Int;
  public var hp:Int;
  public var badstatus:String;
  public var badstatus_turn:Int;

  public function new() {
    id = 0;
    hp = 1;
    badstatus = BadStatusUtil.toString(BadStatus.None);
    badstatus_turn = 0;
  }

  public function copyFromDynamic(p):Void {
    id = p.id;
    hp = p.hp;
    badstatus = p.badstatus;
    badstatus_turn = p.badstatus_turn;
  }
}
