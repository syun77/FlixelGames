package jp_2dgames.game.token;
import flixel.util.FlxVelocity;
import jp_2dgames.lib.MyMath;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * ゲームオブジェクトの基底クラス
 **/
class Token extends FlxSprite {

  public static function checkHitCircle(obj1:Token, obj2:Token):Bool {
    var dx = obj1.xcenter - obj2.xcenter;
    var dy = obj1.ycenter - obj2.ycenter;
    var r1 = obj1.radius;
    var r2 = obj2.radius;

    return (dx*dx + dy*dy) < (r1*r1 + r2*r2);
  }

  public var left(get, never):Float;
  private function get_left() {
    return x;
  }
  public var right(get, never):Float;
  private function get_right() {
    return x + width;
  }

  // 中心座標(X)
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x - offset.x;
  }
  // 中心座標(Y)
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y - offset.y;
  }
  // 半径
  public var radius(get, never):Float;
  public function get_radius() {
    return 8;
  }
  // 開始座標
  public var xstart:Float = 0.0;
  public var ystart:Float = 0.0;
  private function setStartPosition(px:Float, py:Float) {
    xstart = px;
    ystart = py;
  }
  // 前回の座標
  public var xprev:Float = 0.0;
  public var yprev:Float = 0.0;

  /**
   * 画面外に出たかどうか
   **/
  public function isOutside():Bool {

//    return isOnScreen() == false;

    var bottom = FlxG.camera.scroll.y + FlxG.height;
    return y > bottom;
  }

  /**
   * 極座標系で速度を設定
   **/
  public function setVelocity(deg:Float, speed:Float):Void {
    velocity.x = speed * MyMath.cosEx(deg);
    velocity.y = speed * -MyMath.sinEx(deg);
  }

  /**
   * 速度を減衰する
   **/
  public function decayVelocity(d:Float):Void {
    velocity.x *= d;
    velocity.y *= d;
  }

  override public function update():Void {
    // 前回の座標を保存
    xprev = x;
    yprev = y;
    super.update();
  }

  public function updateMotionX():Void {
    xprev = x;
    var dt:Float = FlxG.elapsed;
    var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x);
    velocity.x += velocityDelta;
    var delta = velocity.x * dt;
    velocity.x += velocityDelta;
    x += delta;
  }
  public function updateMotionY():Void {
    yprev = y;
    var dt:Float = FlxG.elapsed;
    var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y);
    velocity.y += velocityDelta;
    var delta = velocity.y * dt;
    velocity.y += velocityDelta;
    y += delta;
  }
}
