package jp_2dgames.game.actor;

import jp_2dgames.game.dat.MyDB;

/**
 * 属性情報
 **/
@:enum
abstract Attribute(String) from String {
  var Phys = cast AttributesKind.Phys;   // 物理
  var Gun  = cast AttributesKind.Gun;    // 銃
  var Fire = cast AttributesKind.Fire;   // 炎
  var Ice  = cast AttributesKind.Ice;    // 氷
  var Shock = cast AttributesKind.Shock; // 雷
  var Wind  = cast AttributesKind.Wind;  // 風
}
