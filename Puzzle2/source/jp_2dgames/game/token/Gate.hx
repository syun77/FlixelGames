package jp_2dgames.game.token;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * プレイヤーを引き寄せるゲート
 **/
class Gate extends Token {

  public static var parent:FlxTypedGroup<Gate> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Gate>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Gate {
    var gate:Gate = parent.recycle(Gate);
    gate.init(X, Y);
    return gate;
  }
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_GATE, true);
    animation.add("play", [0, 1, 2, 3], 8);
    animation.play("play");
  }
  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.SILVER);
    kill();
  }
}
