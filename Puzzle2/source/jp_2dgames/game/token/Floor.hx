package jp_2dgames.game.token;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * One-Way床
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
  public static function add(x:Float, y:Float):Floor {
    var floor:Floor = parent.recycle(Floor);
    floor.init(x, y);
    return floor;
  }

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_TILESET, true, 16, 16);
    animation.add("play", [1], 1);
    animation.play("play");

    // 上からのみ衝突判定がある
    allowCollisions = FlxObject.UP;
    // 衝突しても動かない
    immovable = true;
  }

  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
}
