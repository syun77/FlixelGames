package jp_2dgames.game.token;
import flixel.FlxG;
import jp_2dgames.game.token.Panel.PanelType;

/**
 * パネル操作ユーティリティ
 **/
class PanelUtil {

  public static inline var SWORD:Int  = 1; // 剣
  public static inline var SHIELD:Int = 2; // 盾
  public static inline var SHOES:Int  = 3; // 靴
  public static inline var LIFE:Int   = 4; // ライフ
  public static inline var SKULL:Int  = 5; // ドクロ

  public static inline var FIRST:Int = SWORD;
  public static inline var LAST:Int = SKULL;

  public static function toType(idx:Int):PanelType {
    return switch(idx) {
      case SWORD: PanelType.Sword;
      case SHIELD: PanelType.Shield;
      case SHOES:  PanelType.Shoes;
      case LIFE:   PanelType.Life;
      case SKULL:  PanelType.Skull;
      default: PanelType.Sword;
    }
  }

  public static function toIdx(type:PanelType):Int {
    return switch(type) {
      case PanelType.Sword: SWORD;
      case PanelType.Shield: SHIELD;
      case PanelType.Shoes: SHOES;
      case PanelType.Life: LIFE;
      case PanelType.Skull: SKULL;
    }
  }

  public static function random():Int {
    return FlxG.random.int(FIRST, LAST);
  }
}
