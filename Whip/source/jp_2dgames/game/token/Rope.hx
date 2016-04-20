package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.MyMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * 状態
 **/
private enum State {
  Disconnect; // 切断
  Throw;      // 投げている
  Connecting; // 接続
}

/**
 * ロープ
 **/
class Rope extends FlxSpriteGroup {

  static inline var MAX_SPRITE:Int = 8;
  // ロープの長さ
  static inline var MAX_DISTANCE:Float = Field.GRID_SIZE*3;
  static inline var MIN_DISTANCE:Float = 10.0;
  static inline var DISTANCE_ADD:Float = 1.0;

  // ロープを投げる速度
  static inline var THROW_SPEED:Float = 200.0;
  static inline var TIMER_THROW:Int = 8;

  // ----------------------------------------------
  // ■フィールド
  var _state:State = State.Disconnect; // 状態

  // 始点（プレイヤーと同じ座標）
  var _xstart:Float = 0.0;
  var _ystart:Float = 0.0;
  // 終点（ロープがオブジェクトに引っかかっている座標）
  var _xend:Float = 0.0;
  var _yend:Float = 0.0;

  // ロープの長さ
  var _distance:Float = 0.0;
  // ロープ投げの開始座標
  var _xthrowstart:Float = 0.0;
  var _ythrowstart:Float = 0.0;
  // ロープの投げる速度
  var _xthrowspeed:Float = 0.0;
  var _ythrowspeed:Float = 0.0;
  // ロープ投げたタイマー
  var _tThrow:Int;

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
    _xstart = px - 2;
    _ystart = py - 2;
  }

  public function setEndPosition(px:Float, py:Float):Void {
    _xend = px;
    _yend = py;

    // ロープの長さを計算
    _calcDistance();

    // ロープがつながった
    _connect();
  }

  /**
   * ロープの長さを計算
   **/
  function _calcDistance():Void {
    var dx = _xend - _xstart;
    var dy = _yend - _ystart;
    _distance = Math.sqrt(dx*dx + dy*dy);
  }

  /**
   * ロープ投げ開始
   **/
  public function startThrow(dir:Dir):Void {
    if(_state != State.Disconnect) {
      trace('Error: Rope.startThrow() Invalid state = ${_state} dir = ${dir}');
      return;
    }

    _xend = _xstart;
    _yend = _ystart;
    _xthrowstart = _xstart;
    _ythrowstart = _ystart;
    var pt = DirUtil.getVector(dir);
    _xthrowspeed = THROW_SPEED * pt.x;
    _ythrowspeed = THROW_SPEED * pt.y;
    pt.put();

    visible = true;
    _state = State.Throw;
    _tThrow = 0;
  }

  // ロープを延ばす
  public function extend():Void {
    _distance += DISTANCE_ADD;
    if(_distance > MAX_DISTANCE) {
      // 最大長を超えないようにする
      _distance = MAX_DISTANCE;
    }
  }
  // ロープを縮める
  public function contract():Void {
    _distance -= DISTANCE_ADD;
    if(_distance < MIN_DISTANCE) {
      // 最小より小さくならないようにする
      _distance = MIN_DISTANCE;
    }
  }

  /**
   * ロープ接続
   **/
  function _connect():Void {
    visible = true;
    _state = State.Connecting;
  }

  /**
   * ロープを切断する
   **/
  public function disconnect():Void {
    visible = false;
    _state = State.Disconnect;
  }

  public function isConnect():Bool {
    return _state == State.Connecting;
  }

  public function isThrowable():Bool {
    switch(_state) {
      case State.Connecting:
        return false;
      case State.Throw:
        return false;
      case State.Disconnect:
        return true;
    }
  }

  public function getAngle():Float {
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

    // スプライト描画座標の更新
    _updateSpritePosition();

    switch(_state) {
      case State.Disconnect:
      case State.Throw:
        _updateThrow(elapsed);
      case State.Connecting:
    }
  }

  /**
   * 更新・ロープ投げ
   **/
  function _updateThrow(elapsed:Float):Void {

    _xend += _xthrowspeed * elapsed;
    _yend += _ythrowspeed * elapsed;

    var dx = _xend - _xthrowstart;
    var dy = _yend - _ythrowstart;
    var dist = Math.sqrt(dx*dx + dy*dy);
    if(dist > MAX_DISTANCE) {
      // 届かなかった
      _xthrowspeed *= 0.7;
      _ythrowspeed *= 0.7;
      _tThrow++;
      if(_tThrow > TIMER_THROW) {
        // 消滅
        disconnect();
      }
    }
  }

  /**
   * スプライト描画座標の更新
   **/
  function _updateSpritePosition():Void {
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
