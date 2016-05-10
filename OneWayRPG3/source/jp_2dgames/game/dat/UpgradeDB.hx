package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アップグレードコスト
 **/
class UpgradeDB {

  public static function get(level:Int):Upgrades {
    for(info in MyDB.upgrades.all) {
      if(info.level == level) {
        return info;
      }
    }

    // 見つからなかったら0番目(無効なデータ)を返す
    return MyDB.upgrades.all[0];
  }

  public static function getHpMax(level:Int):Int {
    return get(level).hpmax;
  }
  public static function getDex(level:Int):Int {
    return get(level).dex;
  }
  public static function getAgi(level:Int):Int {
    return get(level).agi;
  }
}
