package jp_2dgames.game.token;

import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;

class Ball extends FlxNapeSprite {

  static inline var RADIUS:Float = 8.0;

  public static var parent:FlxTypedGroup<Ball> = null;
  public static function createParent(state:FlxNapeState):Void {
    parent = new FlxTypedGroup<Ball>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(number:Int, X:Float, Y:Float):Ball {
    var ball = parent.recycle(Ball);
    ball.init(number, X, Y);
    return ball;
  }

  // ------------------------------------------------------------
  // ■フィールド
  var _number:Int;
  var number(get, never):Int;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BALL);
    createCircularBody(RADIUS);

    var elasticity = 1; // 弾力性
    var friction = 2; // 摩擦係数
    setBodyMaterial(elasticity, friction, friction, 1, friction);
    var drag = 0.99; // 移動摩擦係数
    setDrag(drag, drag);
  }

  public function init(number:Int, X:Float, Y:Float):Void {
    _number = number;
    x = X;
    y = Y;
    body.position.setxy(X, Y);

    color = _toColor();
  }

  override public function update():Void {
    super.update();

    if(body.velocity.length < 5) {
      body.velocity.setxy(0, 0);
    }
  }

  function get_number() {
    return _number;
  }

  function _toColor():Int {
    switch(_number) {
      case 0: return FlxColor.WHITE; // プレイヤー
      case 1: return FlxColor.YELLOW; // 黄色
      case 2: return FlxColor.BLUE;
      case 3: return FlxColor.RED;
      case 4: return FlxColor.PURPLE;
      case 5: return FlxColor.CORAL;
      case 6: return FlxColor.LIME;
      case 7: return FlxColor.BROWN;
      case 8: return FlxColor.GRAY;
      default:
        return FlxColor.WHITE;
    }
  }
}
