package jp_2dgames.game.token;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 一方向床
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
  public static function add(X:Float, Y:Float):Floor {
    var floor = parent.recycle(Floor);
    floor.init(X, Y);
    return floor;
  }
  public static function reverseAll():Void {
    parent.forEachAlive(function(floor:Floor) {
      floor._reverse();
    });
  }

  // ----------------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_FLOOR);
    immovable = true;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    allowCollisions = FlxObject.UP;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball2, xcenter, ycenter, FlxColor.GRAY);
    kill();
  }

  function _reverse():Void {
    if(allowCollisions == FlxObject.UP) {
      allowCollisions = FlxObject.DOWN;
    }
    else {
      allowCollisions = FlxObject.UP;
    }
  }
}
