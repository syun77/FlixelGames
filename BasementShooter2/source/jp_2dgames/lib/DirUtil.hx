package jp_2dgames.lib;

import flixel.util.FlxRandom;
import flixel.util.FlxPoint;

/**
 * 方向
 */
enum Dir {
  None;  // なし

  Left;  // 左
  Up;    // 上
  Right; // 右
  Down;  // 下

  LeftUp;    // 左上
  RightUp;   // 右上
  RightDown; // 右下
  LeftDown;  // 左上
}

class DirUtil {

  /**
	 * 定数を文字列に変換
   **/
  public static function toString(dir:Dir):String {
    switch(dir) {
      case Dir.None:      return "none";
      case Dir.Left:      return "left";
      case Dir.Up:        return "up";
      case Dir.Right:     return "right";
      case Dir.Down:      return "down";
      case Dir.LeftUp:    return "left-up";
      case Dir.RightUp:   return "right-up";
      case Dir.RightDown: return "right-down";
      case Dir.LeftDown:  return "left-down";
    }
  }

  /**
   * 文字列を定数に変換
   **/
  public static function fromString(str:String):Dir {
    switch(str) {
      case "none":       return Dir.None;
      case "left":       return Dir.Left;
      case "up":         return Dir.Up;
      case "right":      return Dir.Right;
      case "down":       return Dir.Down;
      case "random":     return random();
      case "left-up":    return Dir.LeftUp;
      case "right-up":   return Dir.RightUp;
      case "right-down": return Dir.RightDown;
      case "left-down":  return Dir.LeftDown;
      default:           return Dir.Down;
    }
  }

  /**
   * 移動ベクトルを取得する
   **/
  public static function getVector(dir:Dir):FlxPoint {
    var a = 0.7071067811865476; // 斜め移動の速度
    var pt = FlxPoint.get();
    switch(dir) {
      case Dir.Left:      pt.set(-1, 0);
      case Dir.Up:        pt.set(0,  -1);
      case Dir.Right:     pt.set(1,  0);
      case Dir.Down:      pt.set(0,  1);
      case Dir.LeftUp:    pt.set(-a, -a);
      case Dir.RightUp :  pt.set(a, -a);
      case Dir.RightDown: pt.set(a, a);
      case Dir.LeftDown:  pt.set(-a, a);
      default:
    }

    return pt;
  }

  /**
	 * 指定方向に移動する
	 **/
  public static function move(dir:Dir, pt:FlxPoint):FlxPoint {
    // 斜めの移動量
    var a:Int = 1;

    switch(dir) {
      case Dir.Left:      pt.x -= 1;
      case Dir.Up:                   pt.y -= 1;
      case Dir.Right:     pt.x += 1;
      case Dir.Down:                 pt.y += 1;
      case Dir.LeftUp:    pt.x -= a; pt.y -= a;
      case Dir.RightUp:   pt.x += a; pt.y -= a;
      case Dir.RightDown: pt.x += a; pt.y += a;
      case Dir.LeftDown:  pt.x -= a; pt.y += a;
      case Dir.None:
      // 何もしない
    }
    return pt;
  }

  /**
	 * 水平方向かどうか
	 **/
  public static function isHorizontal(dir:Dir):Bool {
    switch(dir) {
      case Dir.Left:
        return true;
      case Dir.Right:
        return true;
      default:
        return false;
    }
  }

  /**
	 * 垂直方向かどうか
	 **/
  public static function isVertical(dir:Dir):Bool {
    switch(dir) {
      case Dir.Up:
        return true;
      case Dir.Down:
        return true;
      default:
        return false;
    }
  }

  /**
	 * 入力キーを方向に変換する
	 * @return 入力した方向
	 **/
  public static function getInputDirectionOn(allowDiag:Bool=false):Dir {

    if(allowDiag) {
      // 斜め判定あり
      if(Input.on.LEFT && Input.on.UP) {
        return Dir.LeftUp;
      }
      if(Input.on.RIGHT && Input.on.UP) {
        return Dir.RightUp;
      }
      if(Input.on.RIGHT && Input.on.DOWN) {
        return Dir.RightDown;
      }
      if(Input.on.LEFT && Input.on.DOWN) {
        return Dir.LeftDown;
      }
    }

    if(Input.on.LEFT) {
      return Dir.Left;
    }
    else if(Input.on.RIGHT) {
      return Dir.Right;
    }
    else if(Input.on.UP) {
      return Dir.Up;
    }
    else if(Input.on.DOWN) {
      return Dir.Down;
    }
    else {
      // 入力がない
      return Dir.None;
    }
  }

  /**
   * 方向を反転する
   **/
  public static function invert(dir):Dir {
    switch(dir) {
      case Dir.Left:      return Dir.Right;
      case Dir.Up:        return Dir.Down;
      case Dir.Right:     return Dir.Left;
      case Dir.Down:      return Dir.Up;
      case Dir.LeftUp:    return Dir.RightDown;
      case Dir.RightUp:   return Dir.LeftDown;
      case Dir.RightDown: return Dir.LeftUp;
      case Dir.LeftDown:  return Dir.RightUp;
      default: return Dir.None;
    }
  }

  /**
   * ランダムな方向を返す
   **/
  public static function random(allowDiag:Bool=false):Dir {
    var cnt = 3;
    if(allowDiag) {
      // 斜めあり
      cnt = 7;
    }

    switch(FlxRandom.intRanged(0, cnt)) {
      case 0: return Dir.Left;
      case 1: return Dir.Up;
      case 2: return Dir.Right;
      case 3: return Dir.Down;
      case 4: return Dir.LeftUp;
      case 5: return Dir.RightUp;
      case 6: return Dir.RightDown;
      case 7: return Dir.LeftDown;
      default: return Dir.None;
    }
  }

  /**
   * 2点からなる線分の方向を取得する
   **/
  public static function look(x1:Float, y1:Float, x2:Float, y2:Float):Dir {
    var dx = x2 - x1;
    var dy = y2 - y1;
    if(Math.abs(dx) > Math.abs(dy)) {
      if(dx > 0) {
        return Dir.Right;
      }
      else {
        return Dir.Left;
      }
    }
    else {
      if(dy > 0) {
        return Dir.Down;
      }
      else {
        return Dir.Up;
      }
    }
  }

  /**
   * 方向を角度に変換する
   **/
  public static function toDegree(dir:Dir):Float {
    switch(dir) {
      case Dir.None:      return 0;
      case Dir.Left:      return 180;
      case Dir.Up:        return 90;
      case Dir.Right:     return 0;
      case Dir.Down:      return -90;
      case Dir.LeftUp:    return 135;
      case Dir.RightUp:   return 45;
      case Dir.RightDown: return -45;
      case Dir.LeftDown:  return -135;
    }
  }
}

