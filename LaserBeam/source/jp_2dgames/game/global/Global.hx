package jp_2dgames.game.global;

class Global {

  public static inline var MAX_LEVEL:Int = 9999999;
  public static inline var MAX_LIFE:Int = 100;
  static inline var START_LEVEL:Int = 2;
  static inline var FIRST_SHOT:Float = 0.0;
  static inline var MAX_SHOT:Float = 100.0;
  static inline var FIRST_MONEY:Int = 0;

  // HP
  static var _life:Float;
  public static var life(get, never):Float;
  // スコア
  static var _score:Int;
  public static var score(get, never):Int;
  // レベル
  static var _level:Int;
  public static var level(get, never):Int;
  // ショットゲージ
  static var _shot:Float;
  public static var shot(get, never):Float;
  // カギの所持数
  static var _keys:Int;
  // お金
  static var _money:Int;
  public static var money(get, never):Int;

  public static function init():Void {

  }

  public static function initGame():Void {
    _life = MAX_LIFE;
    _score = 0;
    _level = START_LEVEL;
    _shot = FIRST_SHOT;
    _money = FIRST_MONEY;
  }

  public static function initLevel():Void {
    _keys = 0;
    _score = 0;
  }

  public static function getLifeRatio():Float {
    return Math.floor(100 * _life / MAX_LIFE);
  }
  public static function isLifeDanger():Bool {
    return getLifeRatio() < 40;
  }
  public static function setLife(v:Float):Void {
    _life = v;
    if(_life > MAX_LIFE) {
      _life = MAX_LIFE;
    }
  }
  public static function addLife(v:Float):Void {
    setLife(_life + v);
  }
  public static function subLife(v:Float):Bool {
    _life -= v;
    if(_life < 0) {
//      _life = 0;
    }
    if(_life <= 0) {
      // 死亡
      return true;
    }

    return false;
  }

  public static function addScore(v:Int):Void {
    _score += v;
  }
  public static function addLevel():Bool {
    _level++;
    if(_level >= MAX_LEVEL) {
      return true;
    }
    return false;
  }
  public static function setLevel(v:Int):Void {
    _level = v;
  }
  public static function subShot(v:Float):Void {
    _shot -= v;
    if(_shot < 0) {
      _shot = 0;
    }
  }
  public static function addShot(v:Float):Void {
    _shot += v;
    if(_shot > MAX_SHOT) {
      _shot = MAX_SHOT;
    }
  }
  public static function getKey():Int {
    return _keys;
  }
  public static function addKey():Void {
    _keys++;
  }
  public static function subKey():Void {
    _keys--;
    if(_keys < 0) {
      _keys = 0;
    }
  }
  public static function hasKey():Bool {
    return  _keys > 0;
  }

  public static function addMoney(v:Int):Void {
    _money += v;
  }
  public static function subMoney(v:Int):Void {
    _money -= v;
  }

  // -----------------------------------------------
  // ■アクセサ
  static function get_life() {
    return _life;
  }
  static function get_score() {
    return _score;
  }
  static function get_level() {
    return _level;
  }
  static function get_shot() {
    return _shot;
  }
  static function get_money() {
    return _money;
  }
}
