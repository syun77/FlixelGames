package jp_2dgames.lib;
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
}
