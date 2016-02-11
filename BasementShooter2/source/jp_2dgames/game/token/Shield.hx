package jp_2dgames.game.token;

import flixel.FlxSprite;
import flixel.util.FlxColor;
/**
 * シールド
 **/
class Shield extends Token {

  static inline var MAX_POWER:Float = 100.0;
  var _power:Float;
  var _bExec:Bool;
  var _spr:FlxSprite;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHIELD);
    _spr = new FlxSprite(0, 0, AssetPaths.IMAGE_SHIELD);

    _power = 0;
    _bExec = false;
  }

  override public function kill():Void {
    _spr.kill();
    super.kill();
  }

  public function getSpr():FlxSprite {
    return _spr;
  }

  public function getRatio():Float {
    return _power / MAX_POWER;
  }
  public function subPower():Void {
    _power *= 0.95;
    _bExec = true;
  }

  public function isEnable():Bool {
    if(getRatio() > 0.3) {
      return true;
    }

    return false;
  }

  override public function get_radius() {
    return Std.int(64 * getRatio());
  }

  override public function update():Void {
    super.update();

    if(_power < MAX_POWER) {
      _power += 1;
    }

    var sc = getRatio();
    scale.set(sc, sc);
    visible = isEnable();

    angle += 1;

    if(_bExec) {
      alpha = 1.0;
      color = FlxColor.WHITE;
    }
    else {
      alpha = 0.3;
      color = FlxColor.YELLOW;
    }
    _bExec = false;

    _spr.x = x;
    _spr.y = y;
    _spr.alpha = alpha;
    _spr.color = color;
    _spr.angle -= 1;
    _spr.scale.set(scale.x, scale.y);
  }
}
