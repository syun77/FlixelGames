package jp_2dgames.game.actor;

import jp_2dgames.game.particle.ParticleSmoke;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.game.token.Token;

/**
 * 行動タイプ
 **/
enum Action {
  None;          // なし
  Standby;       // 待機中
  Act;           // 攻撃
  ActExec;       // 攻撃実行中
  Move;          // 移動
  MoveExec;      // 移動実行中
  TurnEnd;       // ターン終了
}

/**
 * 状態
 **/
enum State {
  KeyInput; // キー入力待ち・待機中

  // アクション
  ActBegin; // 開始
  Act;      // 実行中
  ActEnd;   // 終了

  // 移動
  MoveBegin; // 開始
  Move;      // 移動中
  MoveEnd;   // 終了

  TurnEnd;   // ターン終了
}

/**
 * キャラクター基底クラス
 **/
class Actor extends Token {

  // 1マス進むのにかかるフレーム数
  static inline var TIMER_MOVING:Int = 12;
  // ダメージアニメーションのフレーム数
  static inline var TIMER_DAMAGE:Int = 8;
  // バッドステータスが有効なターン数
  static inline var BADSTATUS_TURN:Int = 10; // 基本は10ターン有効
  static inline var BADSTATUS_SLEEP_TURN:Int = 1; // 眠りは1ターンのみ


  // -------------------------------------------
  // ■フィールド
  var _state:State = State.KeyInput;
  var _stateprev:State = State.KeyInput;
  var _tMove:Int   = 0;
  var _tShake:Int  = 0; // ダメージ揺らし用のタイマー
  var _dir:Dir   = Dir.Down;
  var _xnow:Int = 0;
  var _ynow:Int = 0;
  var _xnext:Int = 0;
  var _ynext:Int = 0;
  var _params:Params = null;
  var _badstatus:BadStatus;
  var _balloon:ActorBalloon; // バッドステータスアイコン

  public var dir(get, never):Dir;
  public var xchip(get, never):Int;
  public var ychip(get, never):Int;
  public var params(get, never):Params;
  public var action(get, never):Action;
  public var badstatus(get, never):BadStatus;
  public var balloon(get, never):ActorBalloon;

  public function new() {
    super();
    _balloon = new ActorBalloon();
  }

  /**
   * 初期化
   **/
  public function init(i:Int, j:Int, dir:Dir, ?params:Params):Void {
    _xnext = i;
    _ynext = j;
    _setPositionNext();
    _params = new Params();
    if(params != null) {
      // パラメータ指定あり
      _params.copyFromDynamic(params);
    }
    _dir = dir;

    // バステ更新
    changeBadStatus(BadStatusUtil.fromString(_params.badstatus), true);
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _balloon.kill();
    super.kill();
  }

  /**
   * 指定の座標に存在するかどうか
   **/
  public function existsPosition(xc:Int, yc:Int):Bool {
    if(xc == xchip && yc == ychip) {
      // 一致した
      return true;
    }
    // 一致しない
    return false;
  }

  /**
   * 更新
   **/
  public function proc():Void {
    // サブクラスで実装する
    throw "Error: Need implement.";
  }

  /**
   * 更新・移動中
   **/
  function _procMove():Bool {

    _tMove++;
    var t = _tMove / TIMER_MOVING;
    var dx = _xnext - _xnow;
    var dy = _ynext - _ynow;
    x = Field.toWorldX(_xnow) + dx * Field.GRID_SIZE * t;
    y = Field.toWorldY(_ynow) + dy * Field.GRID_SIZE * t;

    if(_tMove >= TIMER_MOVING) {
      // 移動完了
      return true;
    }
    else {
      // 移動中
      return false;
    }
  }

  /**
   * 状態遷移
   **/
  function _change(s:State):Void {
    _stateprev = _state;
    _state = s;
  }

  /**
   * 行動開始
   **/
  public function beginAction():Void {
    switch(_state) {
      case State.ActBegin:
        _change(State.Act);
      case State.TurnEnd:
      // 何もしない
      default:
        trace('Error: ${_state}');
    }
  }

  /**
   * 移動開始する
   **/
  public function beginMove():Void {
    switch(_state) {
      case State.MoveBegin:
        _tMove = 0;
        _change(State.Move);
      case State.TurnEnd:
      // 何もしない
      default:
        trace('Error: ${_state}');
    }
  }

  /**
   * 何もせずターンを終了する
   **/
  public function standby():Void {
    _change(Actor.State.TurnEnd);
  }

  /**
   * ターン終了しているかどうか
   **/
  public function isTurnEnd():Bool {
    return _state == State.TurnEnd;
  }

  /**
   * ターン終了
   **/
  public function turnEnd():Void {

    // バッドステータスターン数経過
    if(_badstatus != BadStatus.None) {
      _params.badstatus_turn--;
      if(_params.badstatus_turn <= 0) {
        // バッドステータス治癒
        cureBadStatus();
      }
    }
    _change(State.KeyInput);
  }

  /**
   * バッドステータス回復
   **/
  public function cureBadStatus():Void {
    changeBadStatus(BadStatus.None);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    offset.set(0, 0);
    if(_tShake > 0) {
      _tShake--;
      var ox = 0;
      ox += (_tShake % 4 < 2 ? _tShake : -_tShake) * 2;
      offset.set(ox, 0);
    }

    // バルーン座標更新
    if(_balloon.alive) {
      _balloon.x = xcenter;
      _balloon.y = ycenter - height + _balloon.height/2;
    }
  }

  /**
   * ダメージ処理
   **/
  public function damage(val:Int):Void {
    // TODO:
    _tShake = TIMER_DAMAGE;
    var px = xcenter;
    var py = ycenter;
    Particle.start(PType.Ball, px, py, FlxColor.RED);
//    var p = ParticleNumber.start(px, py, val);
//    p.color = 0xFFFFC0C0;

  }

  /**
   * 指定の座標にワープする
   **/
  public function warp(xc:Int, yc:Int):Void {
    var dx = -16;
    var dy = -16;
    ParticleSmoke.start("warp", x+dx, y+dy);
    _xnext = xc;
    _ynext = yc;
    _setPositionNext();
    // ワープエフェクト
    ParticleSmoke.start("warp", x+dx, y+dy);
  }

  /**
   * バッドステータスにする
   **/
  public function changeBadStatus(bst:BadStatus, bSilent:Bool=false):Void {
    _badstatus = bst;
    _params.badstatus = BadStatusUtil.toString(bst);
    _params.badstatus_turn = BADSTATUS_TURN;
    switch(bst) {
      case BadStatus.Sleep: _params.badstatus_turn = BADSTATUS_SLEEP_TURN;
      default:
    }

    _balloon.show(bst);
  }

  /**
   * xnext / ynext に移動する
   **/
  function _setPositionNext():Void {
    x = Field.toWorldX(_xnext);
    y = Field.toWorldY(_ynext);
    _xnow = _xnext;
    _ynow = _ynext;
  }


  // ---------------------------------------------------
  // ■アクセサ
  function get_xchip() {
    return _xnext;
  }
  function get_ychip() {
    return _ynext;
  }
  function get_params() {
    return _params;
  }
  function get_dir() {
    return _dir;
  }
  function get_action() {
    switch(_state) {
      case State.KeyInput:
        return Action.Standby; // 待機中
      case State.ActBegin:
        return Action.Act; // 攻撃開始
      case State.Act:
        return Action.ActExec; // 攻撃実行中
      case State.MoveBegin:
        return Action.Move; // 移動開始
      case State.Move:
        return Action.MoveExec; // 移動中
      case State.TurnEnd:
        return Action.TurnEnd; // ターン終了
      default:
        // 通常はここにこない
        trace('error: ${_state}');
        return Action.None;
    }
  }
  function get_badstatus() {
    return _badstatus;
  }
  function get_balloon() {
    return _balloon;
  }
}
