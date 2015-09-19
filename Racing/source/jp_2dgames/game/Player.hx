package jp_2dgames.game;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends FlxSprite {
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(Reg.PATH_IMAGE_CAR_RED);

    angle = -90;
  }
}
