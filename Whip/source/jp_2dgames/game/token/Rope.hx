package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * ロープ
 **/
class Rope extends FlxSpriteGroup {

  static inline var MAX_SPRITE:Int = 8;

  // ----------------------------------------------
  // ■フィールド
  var _xstart:Float = 0.0;
  var _ystart:Float = 0.0;
  var _xend:Float = 0.0;
  var _yend:Float = 0.0;
  var _distance:Float = 0.0;

  // ロープがつながっているかどうか
  var _bConnected:Bool = false;

  public var distance(get, never):Float;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    for(i in 0...MAX_SPRITE) {
      var sp = new FlxSprite(0, 0, AssetPaths.IMAGE_JOINT);
      this.add(sp);
    }
  }

  public function setStartPosition(px:Float, py:Float):Void {
    _xstart = px;
    _ystart = py;
  }

  public function setEndPosition(px:Float, py:Float):Void {
    _xend = px;
    _yend = py;

    var dx = _xend - _xstart;
    var dy = _yend - _ystart;
    _distance = Math.sqrt(dx*dx + dy*dy);

    // ロープがつながった
    _connect();
  }

  /**
   * ロープ接続
   **/
  function _connect():Void {
    _bConnected = true;
    visible = true;
  }

  /**
   * ロープを切断する
   **/
  public function disconnect():Void {
    _bConnected = false;
    visible = false;
  }

  public function isConnect():Bool {
    return _bConnected;
  }

  public function getAngle():Float {
    /*
    var dx = _xstart - _xend;
    var dy = _ystart - _yend;
    */
    var dx = _xend - _xstart;
    var dy = _yend - _ystart;
    return MyMath.atan2Ex(-dy, dx);
  }

  public function isMaxLength():Bool {
    var dx = _xend - _xstart;
    var dy = _yend - _ystart;
    var len = Math.sqrt(dx*dx + dy*dy);
    return len >= distance;
  }
  public function getTensile():Float {
    var dx = _xend - _xstart;
    var dy = _yend - _ystart;
    var len = Math.sqrt(dx*dx + dy*dy);
    return len - distance;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var px = _xstart;
    var py = _ystart;
    var dx = (_xend - _xstart) / MAX_SPRITE;
    var dy = (_yend - _ystart) / MAX_SPRITE;

    for(sp in members) {
      sp.x = px;
      sp.y = py;
      px += dx;
      py += dy;
    }
  }

  // -------------------------------------------------------
  // ■アクセサ
  function get_distance() {
    return _distance;
  }
}
