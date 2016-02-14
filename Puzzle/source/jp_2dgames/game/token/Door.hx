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

  var _spr:FlxSprite;
  public var spr(get, never):FlxSprite;
  function get_spr() {
    return _spr;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    _spr = new FlxSprite().loadGraphic(AssetPaths.IMAGE_DOOR);
    _spr.x -= _spr.width/2;
    this.add(_spr);
    var txt = new FlxText(-14, 32, 0, "EXIT");
    txt.alignment = "center";
    this.add(txt);

    FlxTween.tween(txt, {y:txt.y+2}, 1, {ease:FlxEase.backOut, type:FlxTween.PINGPONG});
  }
}
