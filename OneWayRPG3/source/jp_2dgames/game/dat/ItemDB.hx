package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテムDB
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

  public static function getHit(id:ItemsKind):Int {
    return Std.int(get(id).hit * 100);
  }

  public static function getAttribute(id:ItemsKind):AttributesKind {
    return get(id).attr.id;
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

  // 攻撃回数
  public static function getCount(id:ItemsKind):Int {
    return get(id).count;
  }

  // 回復HP量
  public static function getHp(id:ItemsKind):Int {
    return get(id).hp;
  }

  public static function getBuy(id:ItemsKind):Int {
    return get(id).buy;
  }
}
