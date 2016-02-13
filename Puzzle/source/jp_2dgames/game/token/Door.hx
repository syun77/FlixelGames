package jp_2dgames.game.token;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
/**
 * 出口
 **/
class Door extends FlxSpriteGroup {

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    var spr = new FlxSprite().loadGraphic(AssetPaths.IMAGE_DOOR);
    spr.x -= spr.width/2;
    this.add(spr);
    var txt = new FlxText(-14, 32, 0, "EXIT");
    txt.alignment = "center";
    this.add(txt);

    FlxTween.tween(txt, {y:txt.y+2}, 1, {ease:FlxEase.backOut, type:FlxTween.PINGPONG});
  }
}
