package jp_2dgames.lib;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
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
   * 3分間でプレイヤーをゲームから追い出す式
   * 10800フレーム(3分)後に難易度が約2.04倍になる
   */
  public static function calcRank3MIN(frame:Int):Float {
    return Math.sqrt(frame * 0.0001) + 1;
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

  /**
   * 線分と円の交差判定
   * @ref http://www.dango-itimi.com/blog/archives/2006/000858.html
   **/
  public static function intersectLineAndCircle(line1:FlxPoint, line2:FlxPoint, circle:FlxPoint, radius:Float):Bool {

    // 線分始点から終点へのベクトル
    var v = FlxPoint.get(line2.x - line1.x, line2.y - line1.y);
    // 線分始点から円中心へのベクトル
    var c = FlxPoint.get(circle.x - line1.x, circle.y - line1.y);

    // 内積を求める
    var dot = FlxMath.dotProduct(v.x, v.y, c.x, c.y);
    if(dot < 0) {
      // cの長さが円の半径より小さい場合は交差している
      return line1.distanceTo(circle) < radius;
    }

    var dot2 = FlxMath.dotProduct(v.x, v.y, v.x, v.y);
    if(dot > dot2) {
      // 線分の終点と円の中心の距離の自乗を求める
      var len = Math.pow(line2.distanceTo(circle), 2);

      // 円の半径の自乗よりも小さい場合は交差している
      return len < Math.pow(radius, 2);
    }
    else {
      var dot3 = FlxMath.dotProduct(c.x, c.y, c.x, c.y);
      return (dot3 - (dot/dot2)*dot < Math.pow(radius, 2));
    }
  }

  /**
   * 線分と線分の交差判定
   * @ref http://qiita.com/ykob/items/ab7f30c43a0ed52d16f2
   **/
  public static function intersectLineAndLine(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, dx:Float, dy:Float):Bool {
    var ta = (cx - dx) * (ay - cy) + (cy - dy) * (cx - ax);
    var tb = (cx - dx) * (by - cy) + (cy - dy) * (cx - bx);
    var tc = (ax - bx) * (cy - ay) + (ay - by) * (ax - cx);
    var td = (ax - bx) * (dy - ay) + (ay - by) * (ax - dx);

    return tc * td < 0 && ta * tb < 0;
  }

  /**
   * 線分と矩形の交差判定
   **/
  public static function intersectLineAndRect(x1:Float, y1:Float, x2:Float, y2:Float, rect:FlxRect):Bool {

    var left   = rect.left;
    var top    = rect.top;
    var right  = rect.right;
    var bottom = rect.bottom;

    if( intersectLineAndLine( left,  top,    right, top,    x1, y1, x2, y2 ) ) { return true; }
    if( intersectLineAndLine( right, top,    right, bottom, x1, y1, x2, y2 ) ) { return true; }
    if( intersectLineAndLine( right, bottom, left,  bottom, x1, y1, x2, y2 ) ) { return true; }
    if( intersectLineAndLine( left,  bottom, left,  top,    x1, y1, x2, y2 ) ) { return true; }

    return false;
  }
}
