package jp_2dgames.game.token;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 1方向床
 **/
class Floor extends Token {

  public static var parent:FlxTypedGroup<Floor> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Floor>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(fall:Bool, X:Float, Y:Float):Floor {
    var floor = parent.recycle(Floor);
    floor.init(fall, X, Y);
    return floor;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_TILESET, true, Field.GRID_SIZE, Field.GRID_SIZE);
    animation.add("play", [1], 1);
    animation.play("play");
    allowCollisions = FlxObject.UP;
  }

  public function init(fall:Bool, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    immovable = (fall == false);
  }
}
