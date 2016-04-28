package jp_2dgames.game.actor;

import flixel.FlxState;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * アクター管理
 **/
class ActorMgr {

  static var _instance:FlxTypedGroup<Actor> = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new FlxTypedGroup<Actor>();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function add(p:Params):Actor {
    var actor:Actor = _instance.recycle(Actor);
    actor.init(p);
    return actor;
  }
  public static function forEach(func:Actor->Void):Void {
    _instance.forEach(func);
  }
  public static function forEachAlive(func:Actor->Void):Void {
    _instance.forEachAlive(func);
  }

  /**
   * 生存数をカウントする
   **/
  public static function count(group:BtlGroup):Int {
    var ret:Int = 0;
    forEachAlive(function(actor:Actor) {
      switch(group) {
        case BtlGroup.Player:
          if(actor.isPlayer()) {
            ret++;
          }
        case BtlGroup.Enemy:
          if(actor.isPlayer() == false) {
            ret++;
          }
        case BtlGroup.Both:
          ret++;
      }
    });
    return ret;
  }

  /**
   * プレイヤーを取得
   **/
  public static function getPlayer():Actor {
    var ret:Actor = null;
    forEach(function(actor:Actor) {
      if(actor.isPlayer()) {
        ret = actor;
      }
    });

    return ret;
  }

  /**
   * 敵を取得
   **/
  public static function getEnemy():Actor {
    var ret:Actor = null;
    forEach(function(actor:Actor) {
      if(actor.isPlayer() == false) {
        ret = actor;
      }
    });

    return ret;
  }

  // -------------------------------------------
  // ■フィールド


  /**
   * コンストラクタ
   **/
  public function new() {
  }
}
