package jp_2dgames.game.token;

import flixel.FlxG;
import openfl.display.BlendMode;
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
  var _light:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    // 明かり
    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);
    _light.x += Field.GRID_SIZE/2;
    _light.y += Field.GRID_SIZE/2;
    this.add(_light);

    // ドア
    _spr = new FlxSprite().loadGraphic(AssetPaths.IMAGE_DOOR);
    this.add(_spr);

    // 説明テキスト
    var txt = new FlxText(-5, -12, 0, "EXIT");
    txt.alignment = "center";
    this.add(txt);

    FlxTween.tween(txt, {y:txt.y+2}, 0.5, {type:FlxTween.PINGPONG});
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var sc = FlxG.random.float(0.7, 1);
    _light.scale.set(sc, sc);
    _light.alpha = FlxG.random.float(0.2, 0.3);
  }
}
