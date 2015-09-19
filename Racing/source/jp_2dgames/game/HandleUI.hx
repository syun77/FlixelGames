package jp_2dgames.game;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * ハンドルUI
 **/
class HandleUI extends FlxSprite {
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(Reg.PATH_IMAGE_HANDLE);

    color = FlxColor.KHAKI;

    scrollFactor.set(0, 0);
  }
}
