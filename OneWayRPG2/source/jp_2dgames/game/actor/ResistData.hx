package jp_2dgames.game.actor;

import jp_2dgames.game.dat.MyDB;

/**
 * 耐性
 **/
@:enum
abstract Resists(String) from String {
  var Weak       = cast ResistancesKind.Weak;        // 弱点
  var Normal     = cast ResistancesKind.Normal;      // 通常
  var Resistance = cast ResistancesKind.Resistance;  // 耐性
  var Invalid    = cast ResistancesKind.Invalid;     // 無効
}

/**
 * 耐性情報
 **/
class ResistData {

  public var attr:Attribute;
  public var resist:Resists;
  public var value:Float;

  public function new(attr:Attribute, resistance:Resists, value:Float) {
    this.attr   = attr;
    this.resist = resistance;
    this.value  = value;
  }
}

class ResistList {

  var _list:List<ResistData>;
  public var list(get, never):List<ResistData>;

  public function new() {
    _list = new List<ResistData>();
  }

  public function add(data:ResistData):Void {
    _list.add(data);
  }

  function get_list() { return _list; }
}
