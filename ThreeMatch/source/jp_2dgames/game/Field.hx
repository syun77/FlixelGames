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

  public function new() {
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
