package jp_2dgames.lib;

import flixel.util.FlxRandom;
import flixel.util.FlxPoint;

/**
 * 方向
 */
enum Dir {
  None;
  Left;
  Up;
  Right;
  Down;
}

class DirUtil {

  /**
	 * 定数を文字列に変換
   **/
  public static function toString(dir:Dir):String {
    switch(dir) {
      case Dir.None:
        return "none";
      case Dir.Left:
        return "left";
      case Dir.Up:
        return "up";
      case Dir.Right:
        return "right";
      case Dir.Down:
        return "down";
    }
  }

  /**
   * 文字列を定数に変換
   **/
  public static function fromString(str:String):Dir {
    switch(str) {
      case "none":
        return Dir.None;
      case "left":
        return Dir.Left;
      case "up":
        return Dir.Up;
      case "right":
        return Dir.Right;
      case "down":
        return Dir.Down;
      case "random":
        return random();
      default:
        return Dir.Down;
    }
  }

  /**
   * 移動ベクトルを取得する
   **/
  public static function getVector(dir:Dir):FlxPoint {
    var pt = FlxPoint.get();
    switch(dir) {
      case Dir.Left:  pt.set(-1, 0);
      case Dir.Up:    pt.set(0,  -1);
      case Dir.Right: pt.set(1,  0);
      case Dir.Down:  pt.set(0,  1);
      default:
    }

    return pt;
  }

  /**
	 * 指定方向に移動する
	 **/
  public static function move(dir:Dir, pt:FlxPoint):FlxPoint {
    switch(dir) {
      case Dir.Left:
        pt.x -= 1;
      case Dir.Up:
        pt.y -= 1;
      case Dir.Right:
        pt.x += 1;
      case Dir.Down:
        pt.y += 1;
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
  public static function getInputDirection():Dir {
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
   * 入力キーに対応する角度を取得する
   **/
  public static function getInputAngle():Float {
    var x:Float = 0;
    var y:Float = 0;
    if(Input.on.LEFT) {
      x = -1;
    }
    else if(Input.on.RIGHT) {
      x = 1;
    }
    if(Input.on.UP) {
      y = -1;
    }
    else if(Input.on.DOWN) {
      y = 1;
    }

    if(x == 0 && y == 0) {
      return null;
    }

    return MyMath.atan2Ex(-y, x);
  }

  /**
   * 方向を反転する
   **/
  public static function invert(dir):Dir {
    switch(dir) {
      case Dir.Left:  return Dir.Right;
      case Dir.Up:    return Dir.Down;
      case Dir.Right: return Dir.Left;
      case Dir.Down:  return Dir.Up;
      default: return Dir.None;
    }
  }

  /**
   * ランダムな方向を返す
   **/
  public static function random():Dir {
    switch(FlxRandom.intRanged(0, 3)) {
      case 0: return Dir.Left;
      case 1: return Dir.Up;
      case 2: return Dir.Right;
      case 3: return Dir.Down;
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
}

