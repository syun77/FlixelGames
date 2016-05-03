package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテム
 **/
class ItemDB {

  public static function get(id:ItemsKind):Items {
    return MyDB.items.get(id);
  }

  public static function getCategory(id:ItemsKind):Items_category {
    return get(id).category;
  }
  // 武器かどうか
  public static function isWeapon(id:ItemsKind):Bool {
    return getCategory(id) == Items_category.Weapon;
  }

  public static function getName(id:ItemsKind):String {
    return get(id).name;
  }

  public static function getPower(id:ItemsKind):Int {
    return get(id).power;
  }

  public static function getHit(id:ItemsKind):Float {
    return get(id).hit;
  }

  public static function getAttribute(id:ItemsKind):Attributes {
    return get(id).attr;
  }

  public static function getDetail(id:ItemsKind):String {
    return get(id).detail;
  }

  public static function getMin(id:ItemsKind):Int {
    return get(id).min;
  }

  public static function getMax(id:ItemsKind):Int {
    return get(id).max;
  }

}
