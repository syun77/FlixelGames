package jp_2dgames.game;
class Gauge {

  public static inline var MAX:Int = 100;

  static var _power:Int   = 0;
  static var _defense:Int = 0;
  static var _speed:Int   = 0;

  public static var power(get, never):Int;
  public static var defense(get, never):Int;
  public static var speed(get, never):Int;

  /**
   * 初期化
   **/
  public static function init():Void {
    _power = 0;
    _defense = 0;
    _speed = 0;
  }

  public static function addPower(v:Int):Void {
    _power += v;
    if(_power > MAX) {
      _power = MAX;
    }
  }
  public static function addDefense(v:Int):Void {
    _defense += v;
    if(_defense > MAX) {
      _defense = MAX;
    }
  }
  public static function addSpeed(v:Int):Void {
    _speed += v;
    if(_speed > MAX) {
      _speed = MAX;
    }
  }
  public static function subPower(v:Int):Void {
    _power -= v;
    if(_power < 0) {
      _power = 0;
    }
  }
  public static function subDefense(v:Int):Void {
//    _defense -= v;
    _defense -= Std.int(_defense * v / 100);
    if(_defense < 0) {
      _defense = 0;
    }
  }
  public static function subSpeed(v:Int):Void {
    _speed -= v;
    if(_speed < 0) {
      _speed = 0;
    }
  }

  // ------------------------------------------------------
  // ■アクセサ
  static function get_power() {
    return _power;
  }
  static function get_defense() {
    return _defense;
  }
  static function get_speed() {
    return _speed;
  }
}
