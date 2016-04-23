package jp_2dgames.game.token;

import flixel.util.FlxColor;
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
  var _light:FlxSprite;
  var _txt:FlxText;
  var _enabled:Bool;

  public var spr(get, never):FlxSprite;
  public var enabled(get, never):Bool;

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
    _txt = new FlxText(-5, -12, 0, "EXIT");
    _txt.alignment = "center";
    this.add(_txt);

    FlxTween.tween(_txt, {y:_txt.y+2}, 0.5, {type:FlxTween.PINGPONG});


    // 初期状態は無効にしておく
    _enabled = false;
    _light.visible = false;
    _spr.color = FlxColor.GRAY;
    _txt.visible = false;
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

  /**
   * ゴールを有効にする
   **/
  public function setEnable():Void {
    _enabled = true;
    _light.visible = true;
    _txt.visible = true;
    _spr.color = FlxColor.WHITE;
  }

  // --------------------------------------------------------
  // ■アクセサ
  function get_spr() {
    return _spr;
  }
  function get_enabled() {
    return _enabled;
  }
}
