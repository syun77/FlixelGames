package jp_2dgames.game.token;

import jp_2dgames.game.dat.MyDB;

/**
 * 敵情報
 **/
class EnemyInfo {

  public static function load():Void {
    // cdbファイルの読み込み
    var content = openfl.Assets.getText("source/jp_2dgames/game/dat/MyDB.cdb");
    MyDB.load(content);
  }

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
  public static function getRadius(eid:Int):Int {
    return get(eid).radius;
  }
  public static function getScore(eid:Int):Int {
    return get(eid).score;
  }
}
