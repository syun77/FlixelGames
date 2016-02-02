package jp_2dgames.lib;

import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyList;
import flixel.FlxG;

class KeyOn {
  public function new() {}

  public var LEFT(get, never):Bool;

  function get_LEFT() {
    if(FlxG.keys.pressed.LEFT) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.pressed.A) {
        return true;
      }
    }
    if(Pad.on(Pad.LEFT)) {
      return true;
    }
    return false;
  }
  public var RIGHT(get, never):Bool;

  function get_RIGHT() {
    if(FlxG.keys.pressed.RIGHT) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.pressed.D) {
        return true;
      }
    }
    if(Pad.on(Pad.RIGHT)) {
      return true;
    }
    return false;
  }
  public var UP(get, never):Bool;

  function get_UP() {
    if(FlxG.keys.pressed.UP) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.pressed.W) {
        return true;
      }
    }
    if(Pad.on(Pad.UP)) {
      return true;
    }
    return false;
  }
  public var DOWN(get, never):Bool;

  function get_DOWN() {
    if(FlxG.keys.pressed.DOWN) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.pressed.S) {
        return true;
      }
    }
    if(Pad.on(Pad.DOWN)) {
      return true;
    }
    return false;
  }
  public var A(get, never):Bool;

  function get_A() {
    if(Input.checkA(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.A)) {
      return true;
    }
    return false;
  }
  public var B(get, never):Bool;

  function get_B() {
    if(Input.checkB(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.B)) {
      return true;
    }
    return false;
  }
  public var X(get, never):Bool;

  function get_X() {
    if(Input.checkX(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.X)) {
      return true;
    }
    return false;
  }
  public var Y(get, never):Bool;

  function get_Y() {
    if(Input.checkY(FlxG.keys.pressed)) {
      return true;
    }
    if(Pad.on(Pad.Y)) {
      return true;
    }
    return false;
  }
}

class KeyPress {
  public function new() {}

  public var LEFT(get, never):Bool;

  inline function get_LEFT() {
    if(FlxG.keys.justPressed.LEFT) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.justPressed.A) {
        return true;
      }
    }
    if(Pad.press(Pad.LEFT)) {
      return true;
    }
    return false;
  }
  public var RIGHT(get, never):Bool;

  inline function get_RIGHT() {
    if(FlxG.keys.justPressed.RIGHT) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.justPressed.D) {
        return true;
      }
    }
    if(Pad.press(Pad.RIGHT)) {
      return true;
    }
    return false;
  }
  public var UP(get, never):Bool;

  function get_UP() {
    if(FlxG.keys.justPressed.UP) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.justPressed.W) {
        return true;
      }
    }
    if(Pad.press(Pad.UP)) {
      return true;
    }
    return false;
  }
  public var DOWN(get, never):Bool;

  function get_DOWN() {
    if(FlxG.keys.justPressed.DOWN) {
      return true;
    }
    if(Input.ENABLE_WASD) {
      // WASDが有効
      if(FlxG.keys.justPressed.S) {
        return true;
      }
    }
    if(Pad.press(Pad.DOWN)) {
      return true;
    }
    return false;
  }
  public var A(get, never):Bool;

  function get_A() {
    if(Input.checkA(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.A)) {
      return true;
    }
    return false;
  }
  public var B(get, never):Bool;

  function get_B() {
    if(Input.checkB(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.B)) {
      return true;
    }
    return false;
  }
  public var X(get, never):Bool;

  function get_X() {
    if(Input.checkX(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.X)) {
      return true;
    }
    return false;
  }
  public var Y(get, never):Bool;

  function get_Y() {
    if(Input.checkY(FlxG.keys.justPressed)) {
      return true;
    }
    if(Pad.press(Pad.Y)) {
      return true;
    }
    return false;
  }
}

/**
 * キー入力管理
 **/
class Input {

  public static inline var ENABLE_WASD:Bool = true;

  public static var on:KeyOn = new KeyOn();
  public static var press:KeyPress = new KeyPress();

  public static function checkA(k:FlxKeyList):Bool {
    if(k.check(FlxKey.ENTER)) {
      return true;
    }
    if(k.check(FlxKey.Z)) {
      return true;
    }
    if(FlxG.mouse.justPressed) {
      return true;
    }
    return false;
  }

  public static function checkB(k:FlxKeyList):Bool {
    if(k.check(FlxKey.SHIFT)) {
      return true;
    }
    if(k.check(FlxKey.X)) {
      return true;
    }
    return false;
  }

  public static function checkX(k:FlxKeyList):Bool {
    if(k.check(FlxKey.SPACE)) {
      return true;
    }
    if(k.check(FlxKey.C)) {
      return true;
    }
    return false;
  }

  public static function checkY(k:FlxKeyList):Bool {
    if(k.check(FlxKey.V)) {
      return true;
    }
    return false;
  }
}

