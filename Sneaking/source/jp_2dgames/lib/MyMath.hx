package jp_2dgames.lib;
import flixel.util.FlxMath;
import flixel.util.FlxAngle;
class MyMath {

  /**
   * 2つの角度差を求める
   * @param current 現在の角度
   * @param target  目標の角度
   * @return 角度差(-180.0〜180.0)
   **/
  public static function deltaAngle(current:Float, target:Float):Float {
    // 2つの角度差を求める
    var sub = target - current;

    // 角度差を0〜360度に丸める
    sub -= Math.floor(sub / 360.0) * 360.0;

    // 角度差が-180〜180の範囲に収まるように丸める
    if(sub > 180.0) {
      sub -= 360.0;
    }

    return sub;
  }

  /***
   * サインの値を求める
   * @param deg 角度
   **/
  public static function sinEx(deg:Float):Float {
    return Math.sin(deg * FlxAngle.TO_RAD);
  }

  /**
   * コサインの値を求める
   * @param deg 角度
   **/
  public static function cosEx(deg:Float):Float {
    return Math.cos(deg * FlxAngle.TO_RAD);
  }

  /**
   * Atan2の値を求める
   * @return 角度
   **/
  public static function atan2Ex(dy:Float, dx:Float):Float {
    return Math.atan2(dy, dx) * FlxAngle.TO_DEG;
  }

  /**
   * 視界の内外判定
   * @param x 自分の座標(X)
   * @param y 自分の座標(Y)
   * @param angle 現在向いている角度
   * @param distance 視界の距離
   * @param viewAngle 視野角 (実際はx2の角度になる)
   * @param xtarget 目標物の座標(X)
   * @param ytarget 目標物の座標(Y)
   * @return 視界内にいたらtrue
   **/
  public static function checkView(x:Float, y:Float, angle:Float, distance:Float, viewAngle:Float, xtarget:Float, ytarget:Float):Bool {
    // 視線ベクトルの作成
    var x1 = distance * MyMath.cosEx(angle);
    var y1 = distance * -MyMath.sinEx(angle);
    var mag1 = FlxMath.vectorLength(x1, y1);
    // 自分とターゲットからなるベクトルを求める
    var x2 = xtarget - x;
    var y2 = ytarget - y;
    var mag2 = FlxMath.vectorLength(x2, y2);
    // 内積を求める
    var dot = FlxMath.dotProduct(x1, y1, x2, y2);
    dot /= (mag1 * mag2); // 内積を正規化
    var rad = Math.acos(dot);
    var ang = FlxAngle.TO_DEG * rad;
    if(ang > viewAngle) {
      // 視界外
      return false;
    }

    // 視界内
    return true;
  }
}
