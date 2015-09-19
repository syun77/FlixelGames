package jp_2dgames.lib;
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
}
