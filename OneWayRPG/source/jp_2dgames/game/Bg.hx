package jp_2dgames.game;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 背景
 **/
class Bg extends FlxSprite {
  public function new() {
    super();
    loadGraphic("assets/images/bg/001.jpg");
    color = FlxColor.GRAY;
  }
}
