package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 装備アイテム
 **/
class ItemEquipment {

  public static function get(itemid:Int):Equipment {
    for(info in MyDB.equipment.all) {
      if(itemid == info.id) {
        return info;
      }
    }

    throw 'Error: Invalid itemid = ${itemid}';
  }

  public static function getName(itemid:Int):String {
    return get(itemid).name;
  }

  public static function getPower(itemid:Int):Int {
    return get(itemid).power;
  }

  public static function getHit(itemid:Int):Int {
    return get(itemid).hit;
  }

  public static function getAttribute(itemid:Int):String {
    return get(itemid).attr;
  }

  public static function getDetail(itemid:Int):String {
    return get(itemid).detail;
  }
}
