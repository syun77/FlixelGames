package jp_2dgames.lib;

import flixel.FlxG;
import flixel.math.FlxPoint;

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
    return switch(dir) {
      case Dir.None:  "none";
      case Dir.Left:  "left";
      case Dir.Up:    "up";
      case Dir.Right: "right";
      case Dir.Down:  "down";
    }
  }

  /**
   * 文字列を定数に変換
   **/
  public static function fromString(str:String):Dir {
    return switch(str) {
      case "none":   Dir.None;
      case "left":   Dir.Left;
      case "up":     Dir.Up;
      case "right":  Dir.Right;
      case "down":   Dir.Down;
      case "random": random();
      default:       Dir.Down;
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
    return switch(dir) {
      case Dir.Left, Dir.Right: true;
      default: false;
    }
  }

  /**
   * 垂直方向かどうか
   **/
  public static function isVertical(dir:Dir):Bool {
    return switch(dir) {
      case Dir.Up, Dir.Down: return true;
      default: false;
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
      return -1000;
    }

    return MyMath.atan2Ex(-y, x);
  }

  /**
   * 方向を反転する
   **/
  public static function invert(dir:Dir):Dir {
    return switch(dir) {
      case Dir.Left:  Dir.Right;
      case Dir.Up:    Dir.Down;
      case Dir.Right: Dir.Left;
      case Dir.Down:  Dir.Up;
      default: Dir.None;
    }
  }
  public static function reverse(dir:Dir):Dir {
    return invert(dir);
  }

  /**
   * 方向を角度に変換する
   **/
  public static function toAngle(dir:Dir):Float {
    switch(dir) {
      case Dir.Left:  return 180;
      case Dir.Up:    return 90;
      case Dir.Right: return 0;
      case Dir.Down:  return -90;
      case Dir.None:  return 0;
    }
  }

  /**
   * ランダムな方向を返す
   **/
  public static function random():Dir {
    switch(FlxG.random.int(0, 3)) {
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

