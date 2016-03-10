package jp_2dgames.game;

/**
 * フィールド
 **/
class Field {

  public static inline var GRID_SIZE:Int = 16;
  public static inline var WIDTH:Int = 8;
  public static inline var HEIGHT:Int = 8;
  public static inline var GRID_WIDTH:Int = GRID_SIZE * WIDTH;
  public static inline var GRID_HEIGHT:Int = GRID_SIZE * HEIGHT;

  public static var xofs(get, never):Int;
  public static var yofs(get, never):Int;

  public static function toWorldX(i:Int):Float {
    return xofs + i * GRID_SIZE;
  }
  public static function toWorldY(j:Int):Float {
    return yofs + j * GRID_SIZE;
  }
  public static function toGridX(x:Float):Int {
    return Std.int((x - xofs) / GRID_SIZE);
  }
  public static function toGridY(y:Float):Int {
    return Std.int((y - yofs) / GRID_SIZE);
  }




  // --------------------------------------------------------------------
  // ■アクセサ
  static function get_xofs() {
    return GRID_SIZE;
  }
  static function get_yofs() {
    return GRID_SIZE;
  }
}
