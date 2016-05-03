package jp_2dgames.game.item;

import jp_2dgames.game.dat.ItemDB;
import jp_2dgames.lib.TextUtil;
import flixel.FlxG;
import jp_2dgames.game.dat.MyDB;

/**
 * アイテム操作のユーティリティ
 **/
class ItemUtil {
  // 無効なアイテムID
  public static inline var NONE:Int = 0;
  // 装備アイテムのオフセットID
  public static inline var OFS_EQUIPMENT:Int = 1000;

  // 名前を取得
  public static function getName(item:ItemData):String {
    var name = getName2(item);
    return '${name} (${item.now}/${item.max})';
  }
  public static function getName2(item:ItemData):String {
    return ItemDB.getName(item.id);
  }

  // 威力を取得
  public static function getPower(item:ItemData):Int {
    return ItemDB.getPower(item.id);
  }

  // 命中率を取得
  public static function getHit(item:ItemData):Int {
    return ItemDB.getHit(item.id);
  }

  // 属性を取得
  public static function getAttribute(item:ItemData):Attributes {
    return ItemDB.getAttribute(item.id);
  }

  // 詳細情報の取得
  public static function getDetail(item:ItemData):String {
    return ItemDB.getDetail(item.id);
  }

  // 詳細情報の取得
  public static function getDetail2(item:ItemData):String {
    var ret = "";
    var str = 0; // TODO:
    var power = ItemUtil.getPower(item);
    var attr  = 0; // TODO:
    var hitratio = ItemUtil.getHit(item);
    var sum = calcDamage(item);
    if(ItemDB.isWeapon(item.id)) {
      //ret += '力: ${str}\n';
      var power = TextUtil.fillSpace(power, 2); // flash対応
      if(item.now == 1) {
        // 最後の一撃
        ret += '攻: ${power} x 3\n';
      }
      else {
        ret += '攻: ${power} \n';
      }
      //ret += '属性: ${attr}\n';
      var sum = TextUtil.fillSpace(sum, 2); // flash対応
      ret += '---------- \n';
      ret += '計: ${sum}ダメージ\n';
      var hitratio = TextUtil.fillSpace(hitratio, 3); // flash対応
      ret += '(命中率: ${hitratio}%)';
    }
    else {
      ret += getDetail(item);
    }

    return ret;
  }

  // ダメージ値取得
  public static function calcDamage(item:ItemData):Int {
    var str = 0; // TODO:
    var power = ItemUtil.getPower(item);
    if(item.now == 1) {
      // 最後の一撃
      power *= 3;
    }
    var attr  = 0; // TODO:
    var hitratio = ItemUtil.getHit(item);
    var sum = str + power;

    return sum;
  }

  public static function getMin(item:ItemData):Int {
    return ItemDB.getMin(item.id);
  }

  public static function getMax(item:ItemData):Int {
    return ItemDB.getMax(item.id);
  }

  /**
   * アイテムを生成
   **/
  public static function add(itemid:ItemsKind):ItemData {
    var item = new ItemData();
    item.id = itemid;
    var min = getMin(item);
    var max = getMax(item);
    item.max = FlxG.random.int(min, max);
    item.now = item.max;

    return item;
  }
}
