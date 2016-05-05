package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 敵DB
 **/
class EnemyDB {

  public static function get(id:EnemiesKind):Enemies {
    return MyDB.enemies.get(id);
  }

  public static function getName(id:EnemiesKind):String {
    return get(id).name;
  }

  public static function getImage(id:EnemiesKind):String {
    return get(id).image;
  }

  public static function getHp(id:EnemiesKind):Int {
    return get(id).hp;
  }

  public static function getAtk(id:EnemiesKind):Int {
    return get(id).atk;
  }

  public static function getHit(id:EnemiesKind):Int {
    return Std.int(get(id).hit * 100);
  }

  public static function lotteryDropItem(id:EnemiesKind):ItemsKind {
    var array = get(id).dropitem;
    if(array.length < 1) {
      // ドロップアイテムなし
      return ItemsKind.None;
    }

    var gen = new LotteryGenerator<ItemsKind>();
    for(drop in array) {
      gen.add(drop.item.id, drop.ratio);
    }

    return gen.exec();
  }
}
