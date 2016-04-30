package jp_2dgames.game.item;

/**
 * アイテム操作のユーティリティ
 **/
class ItemUtil {
  // 無効なアイテムID
  public static inline var NONE:Int = 0;

  public static function getName(item:ItemData):String {
    return '${item.id} (${item.now}/${item.max})';
  }
}
