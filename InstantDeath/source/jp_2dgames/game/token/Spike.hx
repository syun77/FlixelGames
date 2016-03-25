package jp_2dgames.game.token;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

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

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SPIKE, true);
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


  // --------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 4;
  }
}
