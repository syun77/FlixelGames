package jp_2dgames.game;
class Global {

  static inline var MAX_LIFE:Int = 100;

  static var _life:Float;

  public static function init():Void {

  }

  public static function initGame():Void {
    _life = MAX_LIFE;
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
}
