package jp_2dgames.game.token;

/**
 * シールド
 **/
class Shield extends Token {

  static inline var MAX_POWER:Float = 100.0;
  var _power:Float;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHIELD);

    _power = 0;
  }

  public function getRatio():Float {
    return _power / MAX_POWER;
  }
  public function subPower():Void {
    _power *= 0.95;
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
      _power += 0.3;
    }

    var sc = getRatio();
    scale.set(sc, sc);
    visible = isEnable();
  }
}
