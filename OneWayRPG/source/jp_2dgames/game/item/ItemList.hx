package jp_2dgames.game.item;

/**
 * アイテムリスト
 **/
class ItemList {

  public static inline var MAX:Int = 6;

  static var _instance:ItemList = null;

  public static function createInstance():Void {
    _instance = new ItemList();
  }
  public static function push(item:ItemData):Void {
    _instance._push(item);
  }
  public static function del(uid:Int):Void {
    _instance._del(uid);
  }
  public static function isFull():Bool {
    return _instance._isFull();
  }
  public static function isEmpty():Bool {
    return _instance._isEmpty();
  }
  public static function getLength():Int {
    return _instance._getLength();
  }
  public static function getFromIdx(idx:Int):ItemData {
    return _instance._getFromIdx(idx);
  }
  public static function getFromUID(uid:Int):ItemData {
    return _instance._getFromUID(uid);
  }
  public static function dump():Void {
    _instance._dump();
  }

  // -----------------------------------------
  // ■フィールド
  var _pool:Array<ItemData>;

  /**
   * コンストラクタ
   **/
  public function new() {
    _pool = new Array<ItemData>();

  }

  /**
   * アイテムを追加
   **/
  function _push(item:ItemData):Void {
    _pool.push(item);
    _refreshUID();
  }

  /**
   * アイテムを削除
   **/
  function _del(uid:Int):Void {
    var item = _getFromUID(uid);
    _pool.remove(item);
  }

  /**
   * アイテムが最大数に達しているかどうか
   **/
  function _isFull():Bool {
    return _pool.length >= MAX;
  }

  /**
   * アイテムを所持していないかどうか
   **/
  function _isEmpty():Bool {
    return _pool.length == 0;
  }

  /**
   * アイテムの所持数を取得する
   **/
  function _getLength():Int {
    return _pool.length;
  }

  /**
   * アイテムを取得
   **/
  function _getFromIdx(idx:Int):ItemData {
    if(idx >= _pool.length) {
      return null;
    }
    return _pool[idx];
  }
  function _getFromUID(uid:Int):ItemData {
    for(item in _pool) {
      if(item.uid == uid) {
        return item;
      }
    }
    return null;
  }

  /**
   * UIDを更新
   **/
  function _refreshUID():Void {
    var idx = 0;
    for(item in _pool) {
      item.uid = 1000 + idx;
      idx++;
    }
  }

  /**
   * デバッグ出力
   **/
  function _dump():Void {
    for(item in _pool) {
      trace(item.toString());
    }
  }
}
