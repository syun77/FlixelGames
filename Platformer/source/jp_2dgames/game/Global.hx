package jp_2dgames.game;
class Global {

  static inline var MAX_LIFE:Int = 100;

  // HP
  static var _life:Float;
  // スコア
  static var _score:Int;
  // レベル
  static var _level:Int;

  public static function init():Void {

  }

  public static function initGame():Void {
    _life = MAX_LIFE;
    _score = 0;
    _level = 1;
  }

  public static function getLife():Float {
    return _life;
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
    if(_level > 3) {
      // ゲームクリア
      _level = 3;
      return true;
    }
    return false;
  }
}
