package jp_2dgames.game.token;

import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;

/**
 * レーザー
 **/
class Laser extends FlxSprite {

  static var _instance:Laser = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new Laser();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function init(x1:Float, y1:Float, x2:Float, y2:Float):Void {
    _instance._init(x1, y1, x2, y2);
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
  }

  /**
   * 初期化
   **/
  function _init(x1:Float, y1:Float, x2:Float, y2:Float):Void {
    FlxSpriteUtil.drawLine(this, x1, y1, x2, y2);
  }
}
