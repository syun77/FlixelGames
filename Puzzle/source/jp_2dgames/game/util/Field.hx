package jp_2dgames.game.util;

import jp_2dgames.game.token.Block;
import flixel.FlxState;
import jp_2dgames.lib.Array2D;

/**
 * フィールドの管理
 **/
class Field {

  public static inline var TILE_WIDTH:Int = 16;
  public static inline var TILE_HEIGHT:Int = 16;
  public static inline var WIDTH:Int = 15;
  public static inline var HEIGHT:Int = 20;

  static var _instance:Field = null;

  public static function create():Void {
    _instance = new Field();
  }
  public static function destroy():Void {
    _instance = null;
  }

  public static function toWorldX(i:Int):Float {
    return i * TILE_WIDTH;
  }
  public static function toWorldY(j:Int):Float {
    return j * TILE_HEIGHT;
  }
  public static function toGridX(x:Float):Int {
    return Std.int(x);
  }
  public static function toGridY(y:Float):Int {
    return Std.int(y);
  }

  public static function createBlock(state:FlxState):Void {
    _instance._layer.forEach(function(i:Int, j:Int, v:Int) {
      switch(v) {
        case 1:
          Block.add(i, j);
      }
    });
  }


  // =================================================================
  // ■メンバ変数
  var _layer:Array2D;

  /**
   * コンストラクタ
   **/
  public function new() {
    _layer = new Array2D(WIDTH, HEIGHT);
//    var arr = [19, 18, 17, 16, 14, 11, 8, 4, 1];
    var arr = [19, 11];
    for(j in arr) {
      for(i in 1...Field.WIDTH-2) {
        _layer.set(i, j, 1);
      }
    }
  }

}
