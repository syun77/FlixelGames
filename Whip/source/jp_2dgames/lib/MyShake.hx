package jp_2dgames.lib;

import flixel.FlxG;

/**
 * 画面揺らしのプリセット
 **/
class MyShake {

  /**
   * 弱い揺れ
   **/
  public static function low():Void {
    FlxG.camera.shake(0.01, 0.2);
  }

  /**
   * 中くらい
   **/
  public static function middle():Void {
    FlxG.camera.shake(0.02, 0.6);
  }

  /**
   * 強い揺れ
   **/
  public static function high():Void {
    FlxG.camera.shake(0.05, 0.4);
  }
}
