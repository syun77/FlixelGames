package jp_2dgames.game.global;
class Global {

  static inline var MAX_LEVEL:Int = 3;
  static inline var MAX_LIFE:Int = 0;
  static inline var START_LEVEL:Int = 2;
  static inline var MAX_SHOT:Float = 100.0;

  // HP
  static var _life:Float;
  // スコア
  static var _score:Int;
  // レベル
  static var _level:Int;
  // ショットゲージ
  static var _shot:Float;
  // カギの所持数
  static var _keys:Int;

  public static function init():Void {

  }

  public static function initGame():Void {
    _life = MAX_LIFE;
    _score = 0;
    _level = START_LEVEL;
    _shot = MAX_SHOT;
    _keys = 0;
  }

  public static function getLife():Float {
    return _life;
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
      _life = 0;
    }
    if(_life <= 0) {
      // 死亡
      return true;
    }

    return false;
  }

  public static function getScore():Int {
    return _score;
  }
  public static function addScore(v:Int):Void {
    _score += v;
  }
  public static function getLevel():Int {
    return _level;
  }
  public static function addLevel():Bool {
    _level++;
    if(_level >= MAX_LEVEL) {
      return true;
    }
    return false;
  }
  public static function getShot():Float {
    return _shot;
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
}
