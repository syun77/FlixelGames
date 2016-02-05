package jp_2dgames.game.token;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
/**
 * 下から登れる床
 **/
class Floor extends Token {

  public static var parent:FlxGroup;

  public static function createParent(state:FlxState):Void {
    parent = new FlxGroup();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }

  public static function add(X:Float, Y:Float):Floor {
    var floor = new Floor(X, Y);
    parent.add(floor);
    return floor;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_TILESET, true, 16, 16);
    animation.add("play", [1]);
    animation.play("play");

    // 一方向プラットフォーム
    allowCollisions = FlxObject.UP;
    // 動かない
    immovable = true;
  }
}
