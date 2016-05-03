package jp_2dgames.game.token;
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
  public var right(get, never):Float;
  public var top(get, never):Float;
  public var bottom(get, never):Float;
  public var xcenter(get, never):Float; // 中心座標(X)
  public var ycenter(get, never):Float; // 中心座標(Y)
  public var radius(get, never):Float;  // 半径
  public var xstart:Float = 0.0;        // 開始座標(X)
  public var ystart:Float = 0.0;        // 開始座標(Y)
  public var xprev(get, never):Float; // 前回の座標(X)
  public var yprev(get, never):Float; // 前回の座標(Y)

  /**
   * 画面外に出たかどうか
   **/
  public function isOutside():Bool {

    return isOnScreen() == false;

//    var bottom = FlxG.camera.scroll.y + FlxG.height;
//    return y > bottom;
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

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  /**
   * 開始座標を設定
   **/
  private function setStartPosition(px:Float, py:Float) {
    xstart = px;
    ystart = py;
  }

  /**
   * 画面内に入るようにする
   **/
  public function clipScreen():Bool {

    var ret:Bool = false;

    var left = FlxG.camera.scroll.x;
    var right = FlxG.camera.scroll.x + FlxG.width - width;
    if(x < left) {
      x = left;
      ret = true;
    }
    if(x > right) {
      x = right;
      ret = true;
    }
    var top = FlxG.camera.scroll.y;
    var bottom = FlxG.camera.scroll.y + FlxG.height - height;
    if(y < top) {
      y = top;
      ret = true;
    }
    if(y > bottom) {
      y = bottom;
      ret = true;
    }

    return ret;
  }

  // ---------------------------------------------------------------
  // ■アクセサ
  function get_left():Float {
    return x;
  }
  function get_right():Float {
    return x + width;
  }
  function get_top():Float {
    return y;
  }
  function get_bottom():Float {
    return y + height;
  }
  public function get_xcenter():Float {
    return x + origin.x - offset.x;
  }
  public function get_ycenter():Float {
    return y + origin.y - offset.y;
  }
  public function get_radius():Float {
    return width;
  }
  private function get_xprev():Float {
    return last.x;
  }
  private function get_yprev():Float {
    return last.y;
  }
}
