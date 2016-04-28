package jp_2dgames.lib;
/**
 * Class containing a set of useful color constants.
 */
class MyColor {
  /**
   * 0xffff0012
   */
  public static inline var RED:Int = 0xffff0000;

  /**
   * 0xffffff00
   */
  public static inline var YELLOW:Int = 0xffffff00;

  /**
   * 0xff00f225
   */
  public static inline var GREEN:Int = 0xff008000;

  /**
   * 0xff0090e9
   */
  public static inline var BLUE:Int = 0xff0000ff;

  /**
   * 0xfff01eff
   */
  public static inline var PINK:Int = 0xffffc0cb;

  /**
   * 0xff800080
   */
  public static inline var PURPLE:Int = 0xff800080;

  /**
   * 0xffffffff
   */
  public static inline var WHITE:Int = 0xffffffff;

  /**
   * 0xff000000
   */
  public static inline var BLACK:Int = 0xff000000;

  /**
   * 0xff808080
   */
  public static inline var GRAY:Int = 0xff808080;

  /**
   * 0xff964B00
   */
  public static inline var BROWN:Int = 0xff964B00;

  /**
   * 0x00000000
   */
  public static inline var TRANSPARENT:Int = 0x00000000;

  /**
   * Ivory is an off-white color that resembles ivory. 0xfffffff0
   */
  public static inline var IVORY:Int = 0xfffffff0;

  /**
   * Beige is a very pale brown. 0xfff5f5dc
   */
  public static inline var BEIGE:Int = 0xfff5f5dc;

  /**
   * Wheat is a color that resembles wheat. 0xfff5deb3
   */
  public static inline var WHEAT:Int = 0xfff5deb3;

  /**
   * Tan is a pale tone of brown. 0xffd2b48c
   */
  public static inline var TAN:Int = 0xffd2b48c;

  /**
   * Khaki is a light shade of yellow-brown similar to tan or beige. 0xffc3b091
   */
  public static inline var KHAKI:Int = 0xffc3b091;

  /**
   * Silver is a metallic color tone resembling gray that is a representation of the color of polished silver. 0xffc0c0c0
   */
  public static inline var SILVER:Int = 0xffc0c0c0;

  /**
   * Charcoal is a representation of the dark gray color of burned wood. 0xff464646
   */
  public static inline var CHARCOAL:Int = 0xff464646;

  /**
   * Navy blue is a dark shade of the color blue. 0xff000080
   */
  public static inline var NAVY_BLUE:Int = 0xff000080;

  /**
   * Royal blue is a dark shade of the color blue. 0xff084c9e
   */
  public static inline var ROYAL_BLUE:Int = 0xff084c9e;

  /**
   * A medium blue tone. 0xff0000cd
   */
  public static inline var MEDIUM_BLUE:Int = 0xff0000cd;

  /**
   * Azure is a color that is commonly compared to the color of the sky on a clear summer's day. 0xff007fff
   */
  public static inline var AZURE:Int = 0xff007fff;

  /**
   * Cyan is a color between blue and green. 0xff00ffff
   */
  public static inline var CYAN:Int = 0xff00ffff;

  /**
   * Magenta is a color between blue and red. 0xffff00ff
   */
  public static inline var MAGENTA:Int = 0xffff00ff;

  /**
   * Aquamarine is a color that is a bluish tint of cerulean toned toward cyan. 0xff7fffd4
   */
  public static inline var AQUAMARINE:Int = 0xff7fffd4;

  /**
   * Teal is a low-saturated color, a bluish-green to dark medium. 0xff008080
   */
  public static inline var TEAL:Int = 0xff008080;

  /**
   * Forest green is a green color resembling trees and other plants in a forest. 0xff228b22
   */
  public static inline var FOREST_GREEN:Int = 0xff228b22;

  /**
   * Olive is a dark yellowish green or greyish-green color like that of unripe or green olives. 0xff808000
   */
  public static inline var OLIVE:Int = 0xff808000;

  /**
   * Chartreuse is a color halfway between yellow and green. 0xff7fff00
   */
  public static inline var CHARTREUSE:Int = 0xff7fff00;

  /**
   * Lime is a color three-quarters of the way between yellow and green. 0xffbfff00
   */
  public static inline var LIME:Int = 0xffbfff00;

  /**
   * Golden is one of a variety of yellow-brown color blends used to give the impression of the color of the element gold. 0xffffd700
   */
  public static inline var GOLDEN:Int = 0xffffd700;

  /**
   * Goldenrod is a color that resembles the goldenrod plant. 0xffdaa520
   */
  public static inline var GOLDENROD:Int = 0xffdaa520;

  /**
   * Coral is a pinkish-orange color. 0xffff7f50
   */
  public static inline var CORAL:Int = 0xffff7f50;

  /**
   * Salmon is a pale pinkish-orange to light pink color, named after the color of salmon flesh. 0xfffa8072
   */
  public static inline var SALMON:Int = 0xfffa8072;

  /**
   * Hot Pink is a more saturated version of the color pink. 0xfffc0fc0
   */
  public static inline var HOT_PINK:Int = 0xfffc0fc0;

  /**
   * Fuchsia is a vivid reddish or pink color named after the flower of the fuchsia plant. 0xffff77ff
   */
  public static inline var FUCHSIA:Int = 0xffff77ff;

  /**
   * Puce is a brownish-purple color. 0xffcc8899
   */
  public static inline var PUCE:Int = 0xffcc8899;

  /**
   * Mauve is a pale lavender-lilac color. 0xffe0b0ff
   */
  public static inline var MAUVE:Int = 0xffe0b0ff;

  /**
   * Lavender is a pale tint of violet. 0xffb57edc
   */
  public static inline var LAVENDER:Int = 0xffb57edc;

  /**
   * Plum is a deep purple color. 0xff843179
   */
  public static inline var PLUM:Int = 0xff843179;

  /**
   * Indigo is a deep and bright shade of blue. 0xff4b0082
   */
  public static inline var INDIGO:Int = 0xff4b0082;

  /**
   * Maroon is a dark brownish-red color. 0xff800000
   */
  public static inline var MAROON:Int = 0xff800000;

  /**
   * Crimson is a strong, bright, deep red color. 0xffdc143c
   */
  public static inline var CRIMSON:Int = 0xffdc143c;

  // ------------------------------------------------------------------

  public static inline function strToColor(str:String):Int {
    switch(str) {
      case "white": return MyColor.WHITE;
      case "red": return MyColor.PINK;
      case "green": return MyColor.LIME;
      case "blue": return MyColor.AQUAMARINE;
      case "yellow": return MyColor.YELLOW;
      case "orange": return MyColor.WHEAT;
      default:
        return MyColor.BLACK;
    }
  }

  // Asepriteカラーセット
  public static inline var ASE_BLACK:Int     = 0xFF000000; // 黒
  public static inline var ASE_LAMPBLACK:Int = 0xFF222034; // 濃い黒
  public static inline var ASE_TAUPE:Int     = 0xFF45283C; // 黒
  public static inline var ASE_BROWN:Int     = 0xFF663931; // 茶色
  public static inline var ASE_MAROON:Int    = 0xFF8F563B; // 赤茶色
  public static inline var ASE_ORANGE:Int    = 0xFFDF7126; // オレンジ
  public static inline var ASE_SALMON:Int    = 0xFFD9A066; // オレンジピンク
  public static inline var ASE_PINK:Int      = 0xFFEEC39A; // 肌色
  public static inline var ASE_YELLOW:Int    = 0xFFFBF236; // 黄色
  public static inline var ASE_LIME:Int      = 0xFF99E550; // 黄緑
  public static inline var ASE_LIMEGREEN:Int = 0xFF6ABE30; // 濃い黄緑
  public static inline var ASE_GREEN:Int     = 0xFF37946E; // 緑
  public static inline var ASE_DARKGREEN:Int = 0xFF4B692F; // 暗い緑
  public static inline var ASE_DARKBROWN:Int = 0xFF524B24; // 暗い茶色
  public static inline var ASE_DARKNAVY:Int  = 0xFF323C39; // 暗い紺色
  public static inline var ASE_NAVY:Int      = 0xFF3F3F74; // 濃い紺色
  public static inline var ASE_TEAL:Int      = 0xFF306082; // 青緑
  public static inline var ASE_BLUE:Int      = 0xFF5B6EE1; // 青
  public static inline var ASE_SKYBLUE:Int   = 0xFF639BFF; // 薄い青色
  public static inline var ASE_CYAN:Int      = 0xFF5FCDE4; // 水色
  public static inline var ASE_LIGHTCYAN:Int = 0xFFCBDBFC; // 薄い水色
  public static inline var ASE_WHITE:Int     = 0xFFFFFFFF; // 白
  public static inline var ASE_FRENCHGRAY:Int= 0xFF9BADB7; // 青みがかった灰色
  public static inline var ASE_DARKGRAY:Int  = 0xFF847E87; // 明るい灰色
  public static inline var ASE_GRAY:Int      = 0xFF696A6A; // 灰色
  public static inline var ASE_CHARCOAL:Int  = 0xFF595652; // 石炭色
  public static inline var ASE_PURPLE:Int    = 0xFF76428A; // 紫
  public static inline var ASE_CRIMSON:Int   = 0xFFAC3232; // 濃い赤
  public static inline var ASE_RED:Int       = 0xFFD95763; // 赤
  public static inline var ASE_MAGENTA:Int   = 0xFFD77BBA; // 明るい赤紫色
  public static inline var ASE_DRAKKHAKI:Int = 0xFF8F974A; // 暗い黄土色
  public static inline var ASE_OLIVE:Int     = 0xFF8A8F30; // 暗い黄色
}

