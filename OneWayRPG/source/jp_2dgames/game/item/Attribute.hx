package jp_2dgames.game.item;

@:enum
abstract Attribute(String) from String {
  var NONE  = "none";  // 無

  var PHYS  = "phys";  // 物理
  var GUN   = "gun";   // 銃
  var FIRE  = "fire";  // 炎
  var ICE   = "ice";   // 氷
  var SHOCK = "shock"; // 雷
  var WIND  = "wind";  // 風
}
