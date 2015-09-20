package jp_2dgames.game;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxAngle;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * ハンドルUI
 **/
class HandleUI extends FlxSprite {

  public static inline var HEIGHT:Int = 160;
  static inline var MAX_ANGLE = 30;
  static inline var DECAY_ROLL = 0.2;

  var _player:Player;
  var _prevAngle:Float;

  // 中心座標(X)
  private var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x;
  }
  // 中心座標(Y)
  private var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y;
  }

  public function new(X:Float, Y:Float, player:Player) {

    _player = player;

    super(X, Y);
    loadGraphic(Reg.PATH_IMAGE_HANDLE);
    // 中心に寄せる
    x = FlxG.width/2 - width/2;

    color = FlxColor.KHAKI;

    scrollFactor.set(0, 0);
    _prevAngle = _betweenAngleMouse();
  }


  private function _betweenAngleMouse():Float {
    var dx = (FlxG.mouse.x-FlxG.camera.scroll.x) - xcenter;
    var dy = (FlxG.mouse.y-FlxG.camera.scroll.y) - ycenter;
    var angle = Math.atan2(dy, dx);

    return angle * FlxAngle.TO_DEG;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    var nowAngle = _betweenAngleMouse();
    var d = MyMath.deltaAngle(_prevAngle, nowAngle);
    if(Math.abs(d) < MAX_ANGLE) {
      _player.roll(d);
      angle += d * DECAY_ROLL;
    }
    _prevAngle = nowAngle;
  }
}
