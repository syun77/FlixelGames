package jp_2dgames.game.item;

/**
 * アイテム操作のユーティリティ
 **/
import flixel.FlxG;
import jp_2dgames.game.dat.ItemEquipment;
import jp_2dgames.game.dat.ItemConsumable;
class ItemUtil {
  // 無効なアイテムID
  public static inline var NONE:Int = 0;
  // 装備アイテムのオフセットID
  public static inline var OFS_EQUIPMENT:Int = 1000;

  // 消費アイテムかどうか
  public static function isComsumable(item:ItemData):Bool {
    return (item.id < OFS_EQUIPMENT);
  }

  // 名前を取得
  public static function getName(item:ItemData):String {
    var name = getName2(item);
    return '${name} (${item.now}/${item.max})';
  }
  public static function getName2(item:ItemData):String {
    var name = "";
    if(isComsumable(item)) {
      name = ItemConsumable.getName(item.id);
    }
    else {
      name = ItemEquipment.getName(item.id);
    }
    return name;
  }

  // 威力を取得
  public static function getPower(item:ItemData):Int {
    if(isComsumable(item)) {
      return 0;
    }
    return ItemEquipment.getPower(item.id);
  }

  // 命中率を取得
  public static function getHit(item:ItemData):Int {
    if(isComsumable(item)) {
      return 0;
    }
    return ItemEquipment.getHit(item.id);
  }

  // 属性を取得
  public static function getAttribute(item:ItemData):Attribute {
    if(isComsumable(item)) {
      return Attribute.NONE;
    }
    return ItemEquipment.getAttribute(item.id);
  }

  // 詳細情報の取得
  public static function getDetail(item:ItemData):String {
    if(isComsumable(item)) {
      return ItemConsumable.getDetail(item.id);
    }
    else {
      return ItemEquipment.getDetail(item.id);
    }
  }

  // 詳細情報の取得
  public static function getDetail2(item:ItemData):String {
    var ret = "";
    var str = 0; // TODO:
    var power = ItemUtil.getPower(item);
    var attr  = 0; // TODO:
    var hitratio = ItemUtil.getHit(item);
    var sum = calcDamage(item);
    if(isComsumable(item)) {
      ret += getDetail(item);
    }
    else {
      ret += '力: ${str}\n';
      ret += '攻: ${power}\n';
      ret += '属性: ${attr}\n';
      ret += '----------\n';
      ret += '計: ${sum}ダメージ\n';
      ret += '(命中率: ${hitratio}%)';
    }

    return ret;
  }

  // ダメージ値取得
  public static function calcDamage(item:ItemData):Int {
    var str = 0; // TODO:
    var power = ItemUtil.getPower(item);
    var attr  = 0; // TODO:
    var hitratio = ItemUtil.getHit(item);
    var sum = str + power;

    return sum;
  }

  public static function getMin(item:ItemData):Int {
    if(isComsumable(item)) {
      return ItemConsumable.getMin(item.id);
    }
    else {
      return ItemEquipment.getMin(item.id);
    }
  }

  public static function getMax(item:ItemData):Int {
    if(isComsumable(item)) {
      return ItemConsumable.getMax(item.id);
    }
    else {
      return ItemEquipment.getMax(item.id);
    }
  }

  /**
   * アイテムを生成
   **/
  public static function add(itemid:Int):ItemData {
    var item = new ItemData();
    item.id = itemid;
    var min = getMin(item);
    var max = getMax(item);
    item.max = FlxG.random.int(min, max);
    item.now = item.max;

    return item;
  }
}
