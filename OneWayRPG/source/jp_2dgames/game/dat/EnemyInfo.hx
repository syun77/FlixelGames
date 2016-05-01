package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 敵情報
 **/
class EnemyInfo {
  public static function get(eid:Int):Enemies {
    for(info in MyDB.enemies.all) {
      if(eid == info.id) {
        return info;
      }
    }

    throw 'Error: Invalid eid = ${eid}';
  }
  public static function getHp(eid:Int):Int {
    return get(eid).hp;
  }
  public static function getAtk(eid:Int):Int {
    return get(eid).atk;
  }
  public static function getHit(eid:Int):Int {
    return get(eid).hit;
  }
  public static function getAI(eid:Int):String {
    return get(eid).ai;
  }
  public static function getImage(eid:Int):String {
    return get(eid).image;
  }
  public static function getName(eid:Int):String {
    return get(eid).name;
  }
  public static function getDropItems(eid:Int):Array<Int> {
    var ret = new Array<Int>();
    var drop1 = get(eid).drop1;
    if(drop1 > 0) {
      ret.push(drop1);
    }
    var drop2 = get(eid).drop2;
    if(drop2 > 0) {
      ret.push(drop2);
    }
    var drop3 = get(eid).drop3;
    if(drop3 > 0) {
      ret.push(drop3);
    }
    return ret;
  }
  /*
  public static function getFly(eid:Int):String {
    return get(eid).fly;
  }
  public static function getRadius(eid:Int):Int {
    return get(eid).radius;
  }
  public static function getScore(eid:Int):Int {
    return get(eid).score;
  }
  public static function getDestroy(eid:Int):Float {
    return get(eid).destroy;
  }
  */
}
