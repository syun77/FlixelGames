package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 消費アイテム
 **/
class ItemConsumable {
  public static function get(itemid:Int):Consumable {
    for(info in MyDB.consumable.all) {
      if(itemid == info.id) {
        return info;
      }
    }

    throw 'Error: Invalid itemid = ${itemid}';
  }

  public static function getName(itemid:Int):String {
    return get(itemid).name;
  }

  public static function getDetail(itemid:Int):String {
    return get(itemid).detail;
  }

  public static function getMin(itemid:Int):Int {
    return get(itemid).min;
  }

  public static function getMax(itemid:Int):Int {
    return get(itemid).max;
  }
}
