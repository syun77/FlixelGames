package jp_2dgames.game.item;

/**
 * インベントリ
 **/
class Inventory {

  // アイテムを所持できる最大数
  public static var MAX:Int = 10;

  static var _instance:Inventory = null;
  public static function create():Void {
    _instance = new Inventory();
  }
  public static function add(itemid:Int):Void {
    _instance._add(itemid);
  }
  public static function use(idx:Int):Void {
    _instance._use(idx);
  }
  public static function isFull():Bool {
    return _instance._isFull();
  }
  public static function forEach(func:Int->Int->Void):Void {
    _instance._forEach(func);
  }
  public static function forEachItem(func:Int->Void):Void {
    _instance._forEachItem(func);
  }
  public static function set(list:Array<Int>):Void {
    _instance._set(list);
  }

  // ----------------------------------------------
  // ■フィールド
  var _list:Array<Int>;

  /**
   * コンストラクタ
   **/
  public function new() {
    _list = new Array<Int>();
  }

  /**
   * 追加する
   **/
  function _add(itemid:Int):Void {
    _list.push(itemid);
  }

  /**
   * 使う
   **/
  function _use(idx:Int):Void {
    _list.splice(idx, 1);
  }

  /**
   * 最大所持数に達しているかどうか
   **/
  function _isFull():Bool {
    return _list.length >= MAX;
  }

  /**
   * すべての要素を走査する
   **/
  function _forEach(func:Int->Int->Void):Void {
    for(i in 0...MAX) {
      var itemid = -1;
      if(i < _list.length) {
        itemid = _list[i];
      }
      var type = ItemType.INVALID;
      if(itemid != -1) {
        type = ItemType.get(itemid);
      }
      func(i, type);
    }
  }

  function _forEachItem(func:Int->Void):Void {
    for(itemid in _list) {
      func(itemid);
    }
  }

  function _set(list:Array<Int>):Void {
    _list = list;
  }
}
