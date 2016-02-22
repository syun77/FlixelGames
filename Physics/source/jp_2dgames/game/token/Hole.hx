package jp_2dgames.game.token;
import nape.phys.BodyType;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.addons.nape.FlxNapeState;
import nape.callbacks.CbType;
import flixel.addons.nape.FlxNapeSprite;

/**
 * 穴
 **/
class Hole extends FlxNapeSprite {

  public static var CB_HOLE:CbType = null;

  // コリジョンの半径
  static inline var RADIUS:Float = 8.0;

  public static var parent:FlxTypedGroup<Hole> = null;
  public static function createParent(state:FlxNapeState):Void {
    parent = new FlxTypedGroup<Hole>();
    state.add(parent);
    CB_HOLE = new CbType();
  }
  public static function destroyParent():Void {
    CB_HOLE = null;
    parent = null;
  }
  public static function add(X:Float, Y:Float):Hole {
    var hole = parent.recycle(Hole, [X, Y]);
    return hole;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_HOLE);
    // 動かないのでSTATIC
    createCircularBody(RADIUS, BodyType.STATIC);

    body.cbTypes.add(CB_HOLE);
  }
}
