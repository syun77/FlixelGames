package jp_2dgames.game.dat;

import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.MyDB;

/**
 * 耐性
 **/
enum Resists {
  Weak;        // 弱点
  Normal;      // 通常
  Resistance;  // 耐性
  Invalid;     // 無効
}

class ResistUtil {
  public static function fromKind(kind:ResistancesKind):Resists {
    return switch(kind) {
      case ResistancesKind.Weak:       Resists.Weak;
      case ResistancesKind.Normal:     Resists.Normal;
      case ResistancesKind.Resistance: Resists.Resistance;
      case ResistancesKind.Invalid:    Resists.Invalid;
    }
  }
}

/**
 * 耐性情報
 **/
class ResistData {

  public var attr:Attribute; // 属性
  public var resist:Resists; // 耐性
  public var value:Float;    // 割合

  /**
   * コンストラクタ
   **/
  public function new(attr:Attribute, resistance:Resists, value:Float) {
    this.attr   = attr;
    this.resist = resistance;
    this.value  = value;
  }
}

class ResistList {

  var _list:List<ResistData>;
  var _map:Map<Attribute,ResistData>;
  public var list(get, never):List<ResistData>;

  public function new() {
    _list = new List<ResistData>();
    _map = new Map<Attribute,ResistData>();
  }

  public function add(data:ResistData):Void {
    _list.add(data);
    _map[data.attr] = data;
  }

  function get_list() { return _list; }
}
