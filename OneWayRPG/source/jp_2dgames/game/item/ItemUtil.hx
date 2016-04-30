package jp_2dgames.game.item;

/**
 * アイテム操作のユーティリティ
 **/
import jp_2dgames.game.dat.ItemEquipment;
import jp_2dgames.game.dat.ItemConsumable;
class ItemUtil {
  // 無効なアイテムID
  public static inline var NONE:Int = 0;
  // 装備アイテムのオフセットID
  public static inline var OFS_EQUIPMENT:Int = 1000;

  public static function isComsumable(item:ItemData):Bool {
    return (item.id < OFS_EQUIPMENT);
  }

  public static function getName(item:ItemData):String {
    var name = "";
    if(isComsumable(item)) {
      name = ItemConsumable.getName(item.id);
    }
    else {
      name = ItemEquipment.getName(item.id);
    }
    return '${name} (${item.now}/${item.max})';
  }
}
