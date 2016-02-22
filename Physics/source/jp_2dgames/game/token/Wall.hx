package jp_2dgames.game.token;
import nape.callbacks.CbType;
import nape.phys.BodyType;
import flixel.group.FlxTypedGroup;
import flixel.addons.nape.FlxNapeSprite;

/**
 * 壁
 **/
class Wall extends FlxNapeSprite {

  public static var CB_WALL:CbType = null;

  public static var parent:FlxTypedGroup<Wall> = null;
  public static function createParent(state):Void {
    CB_WALL = new CbType();
    parent = new FlxTypedGroup<Wall>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
    CB_WALL = null;
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

    body.cbTypes.add(CB_WALL);

    body.userData.data = this;
  }
}
