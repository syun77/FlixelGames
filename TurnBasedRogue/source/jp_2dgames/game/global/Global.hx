package jp_2dgames.game.global;
import jp_2dgames.game.actor.Params;
import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.game.actor.Player;
class Global {

  static inline var MAX_LEVEL:Int = 4;
  public static inline var MAX_LIFE:Int = 100;
  static inline var START_LEVEL:Int = 1;
  static inline var MAX_SHOT:Float = 100.0;
  static inline var FIRST_MONEY:Int = 0;
  static inline var FIRST_TURN:Int = 10;

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
  // カギの所持数
  static var _keys:Int;
  // お金
  static var _money:Int;
  public static var money(get, never):Int;
  // 残りターン数
  static var _turn:Int;
  public static var turn(get, never):Int;

  public static function init():Void {

  }

  public static function initGame():Void {
    _life = MAX_LIFE;
    _score = 0;
    _level = START_LEVEL;
    _shot = MAX_SHOT;
    _money = FIRST_MONEY;
    _turn = FIRST_TURN;
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
      _life = 0;
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

  public static function addMoney(v:Int):Void {
    _money += v;
  }
  public static function subMoney(v:Int):Void {
    _money -= v;
  }

  public static function initPlayer(player:Player, x:Int, y:Int, dir:Dir, params:Params):Void {
    player.init(x, y, dir, params);
  }

  public static function subTurn(v:Int):Void {
    _turn -= v;
    if(_turn < 0) {
      _turn = 0;
    }
  }

  public static function addTurn(v:Int):Void {
    _turn += v;
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
  static function get_money() {
    return _money;
  }
  static function get_turn() {
    return _turn;
  }
}
