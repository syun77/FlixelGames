package jp_2dgames.game.token;
import nape.phys.BodyType;
import flixel.group.FlxTypedGroup;
import flixel.addons.nape.FlxNapeSprite;

/**
 * 壁
 **/
class Wall extends FlxNapeSprite {

  public static var parent:FlxTypedGroup<Wall> = null;
  public static function createParent(state):Void {
    parent = new FlxTypedGroup<Wall>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Wall {
    var wall = parent.recycle(Wall, [X, Y]);
    return wall;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_WALL);

    // 動かないのでSTATIC
    createRectangularBody(0, 0, BodyType.STATIC);
  }
}
