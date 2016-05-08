package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * フロア情報
 **/
class FloorInfo {

  public static function get(level:Int):Floorinfo {
    for(info in MyDB.floorinfo.all) {
      if(info.floor == level) {
        return info;
      }
    }

    return null;
  }

  public static function getSteps(level:Int):Int {
    return get(level).steps;
  }

  public static function getBoss(level:Int):EnemiesKind {
    return get(level).boss.id;
  }
}
