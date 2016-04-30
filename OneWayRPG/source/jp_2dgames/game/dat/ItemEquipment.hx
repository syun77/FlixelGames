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
}
