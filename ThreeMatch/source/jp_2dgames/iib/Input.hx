package jp_2dgames.lib;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

/**
 * 入力モード
 **/
private enum KeyMode {
  Press;
  On;
  Release;
}

private class InputKey {
  public var A(get, never):Bool;
  public var B(get, never):Bool;
  public var X(get, never):Bool;
  public var Y(get, never):Bool;
  public var LEFT(get, never):Bool;
  public var UP(get, never):Bool;
  public var RIGHT(get, never):Bool;
  public var DOWN(get, never):Bool;

  var _mode:KeyMode;

  public function new(mode:KeyMode) {
    _mode = mode;
  }

  function get_A() {
    var keys = [FlxKey.Z];
    if(_checkKeys(keys)) {
      return true;
    }
    switch(_mode) {
      case KeyMode.Press:
        if(FlxG.mouse.justPressed) {
          return true;
        }
      case KeyMode.On:
        if(FlxG.mouse.pressed) {
          return true;
        }
      case KeyMode.Release:
        if(FlxG.mouse.justReleased) {
          return true;
        }
    }
    return false;
  }
  function get_B() {
    var keys = [FlxKey.X];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_X() {
    var keys = [FlxKey.C];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_Y() {
    var keys = [FlxKey.V];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_LEFT() {
    var keys = [FlxKey.LEFT];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_UP() {
    var keys = [FlxKey.UP];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_RIGHT() {
    var keys = [FlxKey.RIGHT];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_DOWN() {
    var keys = [FlxKey.DOWN];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }

  function _checkKeys(keys:Array<FlxKey>):Bool {
    switch(_mode) {
      case KeyMode.Press:
        if(FlxG.keys.anyJustPressed(keys)) {
          return true;
        }
      case KeyMode.On:
        if(FlxG.keys.anyPressed(keys)) {
          return true;
        }
      case KeyMode.Release:
        if(FlxG.keys.anyJustReleased(keys)) {
          return true;
        }
    }
    return false;
  }

}

private class InputMouse {
  public var x(get, never):Float;
  public var y(get, never):Float;

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  function get_x() {
    return FlxG.mouse.x;
  }
  function get_y() {
    return FlxG.mouse.y;
  }
}

/**
 * 入力管理
 **/
class Input {

  public static var mouse:InputMouse = new InputMouse();
  public static var press:InputKey = new InputKey(KeyMode.Press);
  public static var on:InputKey = new InputKey(KeyMode.On);
  public static var release:InputKey = new InputKey(KeyMode.Release);
}
