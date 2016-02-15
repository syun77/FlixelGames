package jp_2dgames.game.token;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 鉄球
 **/
class Spike extends Token {

  public static var parent:FlxTypedGroup<Spike> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Spike>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Spike {
    var spike:Spike = parent.recycle(Spike);
    spike.init(X, Y);
    return spike;
  }

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SPIKE, true);
    animation.add("play", [0, 1, 2, 3], 8);
    animation.play("play");
  }

  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
}
