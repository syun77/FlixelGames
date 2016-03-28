package jp_2dgames.game;

import jp_2dgames.lib.MyColor;

/**
 * 属性
 **/
enum Attribute {
  Red;  // 赤
  Blue; // 青
}

/**
 * 属性ユーティリティ
 **/
class AttributeUtil {

  /**
   * 属性を反転する
   **/
  public static function invert(attr:Attribute):Attribute {
    return switch(attr) {
      case Attribute.Red:  Attribute.Blue;
      case Attribute.Blue: Attribute.Red;
    }
  }

  /**
   * 属性に対応する色を取得する
   **/
  public static function toColor(attr:Attribute):Int {
    return switch(attr) {
      case Attribute.Red:  MyColor.CRIMSON;
      case Attribute.Blue: MyColor.AZURE;
    }
  }
}
