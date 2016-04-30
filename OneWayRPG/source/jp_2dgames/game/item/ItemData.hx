package jp_2dgames.game.item;

/**
 * アイテムデータ
 **/
class ItemData {

  // 無効なアイテムID
  public static inline var NONE:Int = 0;

  public var uid:Int; // ユニーク番号
  public var id:Int;  // アイテムID
  public var now:Int; // 使用回数
  public var max:Int; // 最大使用回数

  /**
   * コンストラクタ
   **/
  public function new() {
    id = NONE;
    now = 0;
    max = 0;
  }

  public function toString():String {
    return '[${uid}] ${id} now=${now} max=${max}';
  }
}
