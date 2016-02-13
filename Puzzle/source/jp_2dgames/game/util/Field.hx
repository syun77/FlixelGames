package jp_2dgames.game.util;

import flixel.addons.ui.FlxClickArea;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import jp_2dgames.game.token.Block;
import flixel.FlxState;
import jp_2dgames.lib.Array2D;

/**
 * フィールドの管理
 **/
class Field {

  public static inline var TILE_WIDTH:Int = 16;
  public static inline var TILE_HEIGHT:Int = 16;
  public static inline var WIDTH:Int = 10;
  public static inline var HEIGHT:Int = 15;

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

  public static function createFloor():FlxGroup {
    var floors = new FlxGroup();
    var floor1 = new FlxSprite(0, 0);
    var color = FlxColor.GRAY;
    floor1.immovable = true;
    floor1.makeGraphic(Field.TILE_WIDTH, FlxG.height, color);
    floors.add(floor1);
    var floor2 = new FlxSprite(FlxG.width-Field.TILE_WIDTH, 0);
    floor2.immovable = true;
    floor2.makeGraphic(Field.TILE_WIDTH, FlxG.height, color);
    floors.add(floor2);
    var floor3 = new FlxSprite(0, FlxG.height-Field.TILE_HEIGHT);
    floor3.immovable = true;
    floor3.makeGraphic(FlxG.width, 128, color);
    floors.add(floor3);

    return floors;
  }

  public static function createBlock():Void {
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
  }

}
