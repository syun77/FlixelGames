package jp_2dgames.game.util;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;
import jp_2dgames.lib.Array2D;

/**
 * フィールドの管理
 **/
class Field {

  public static inline var TILE_WIDTH:Int = 16;
  public static inline var TILE_HEIGHT:Int = 16;
  public static inline var WIDTH:Int = 10;
  public static inline var HEIGHT:Int = 20;

  static var _instance:Field = null;

  public static function create():Void {
    _instance = new Field();
  }
  public static function destroy():Void {
    _instance = null;
  }

  public static function createBlock(state:FlxState):Void {
    _instance._layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = i * 16;
      var y = j * 16;
      switch(v) {
        case 1:
          var spr = new FlxSprite(x, y);
          spr.makeGraphic(16, 16, FlxColor.WHITE);
          state.add(spr);
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
    _layer = new Array2D(10, 20);
    _layer.set(5, 10, 1);
    _layer.set(4, 11, 1);

  }

}
