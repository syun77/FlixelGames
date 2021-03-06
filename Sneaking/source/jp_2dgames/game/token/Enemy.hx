package jp_2dgames.game.token;

import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.game.token.Enemy;
import flixel.util.FlxRandom;
import flixel.util.FlxAngle;
import flixel.ui.FlxAnalog;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxPoint;
import flash.display.BlendMode;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 敵の種類
 **/
enum EnemyType {
  RollCW;     // 時計回り
  RollCCW;    // 反時計回り
  Horizontal; // 左右に移動
  Vertical;   // 上下に移動
}

/**
 * 状態
 **/
private enum State {
  Normal; // 通常
  Sleep;  // 眠り
}

/**
 * 敵
 **/
class Enemy extends Token {

  // 視界
  static inline var VIEW_DISTANCE:Float = 200.0;

  // 視界の旋回速度
  static inline var MAX_TURN_ANGLE:Float = 1.0;
  // 引き返し時間
  static inline var TIMER_BACK:Int = 180;
  // 睡眠時間
  static inline var TIMER_SLEEP:Int = 60;

  public static var parent:FlxTypedGroup<Enemy> = null;
  static var _target:Player = null;
  static var _bFindTarget:Bool = false;

  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>(16);
    for(i in 0...parent.maxSize) {
      var e = new Enemy();
      e.ID = i;
      parent.add(e);
      state.add(e._view);
      state.add(e._balloon);
    }
    state.add(parent);

    // プレイヤー見つけたフラグを初期化
    _bFindTarget = false;
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:EnemyType, X:Float, Y:Float):Enemy {
    var enemy:Enemy = parent.recycle();
    enemy.init(type, X, Y);
    return enemy;
  }

  /**
   * 敵の種類をランダムで決める
   **/
  public static function randomType():EnemyType {
    var tbl = [
      EnemyType.RollCW,
      EnemyType.RollCCW,
      EnemyType.Horizontal,
      EnemyType.Vertical
    ];

    FlxRandom.shuffleArray(tbl, 3);

    return tbl[0];
  }

  public static function setTarget(player:Player):Void {
    _target = player;
  }

  public static function isFindTarget():Bool {
    return _bFindTarget;
  }

  // ------------------------------------------------
  // ■フィールド
  // 行動種別
  var _type:EnemyType;
  // タイマー
  var _timer:Int;

  // 視界の距離
  var _viewDistance:Float = VIEW_DISTANCE;
  // 視野角
  var _viewAngle:Float = 30.0;
  // 視界
  var _view:FlxSprite;
  // 向いている方向
  var _direction:Float;
  // 移動速度
  var _moveSpeed:Float;
  // 旋回速度
  var _rollSpeed:Float;
  // 移動方向
  var _dir:Dir;
  // 状態
  var _state:State;
  // バステタイマー
  var _tBadstatus:Int;
  // 吹き出し
  var _balloon:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PERSON);
    color = FlxColor.LIME;

    _view = new FlxSprite();
    var unique = true;
    _view.makeGraphic(400, 400, FlxColor.TRANSPARENT, unique);
    _view.alpha = 0.2;

    _balloon = new FlxSprite();
    _balloon.loadGraphic(AssetPaths.IMAGE_BALLOON);

    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float):Void {
    x = X;
    y = Y;

    // 最初は下向き
    _direction = -90;

    // 敵の種類
    _type = type;
    _timer = 0;
    _tBadstatus = 0;
    _state = State.Normal;
    velocity.set();

    _viewAngle = LevelMgr.getViewRange();
    _viewDistance = LevelMgr.getViewDistance();

    // 移動速度
    _moveSpeed = 50;
    // 旋回速度
    _rollSpeed = LevelMgr.getViewRoll();
    switch(_type) {
      case EnemyType.Horizontal:
        _dir = Dir.Right;
      case EnemyType.Vertical:
        _dir = Dir.Down;
      default:
        // 移動しない
        _dir = Dir.None;
    }
    _moveDirection();

    // 視界の作成
    _createView();

    _updateView();
    _updateBalloon();
  }

  function _moveDirection():Void {
    var pt = DirUtil.getVector(_dir);
    velocity.x = pt.x * _moveSpeed;
    velocity.y = pt.y * _moveSpeed;
    pt.put();
  }

  /**
   * ダメージ
   **/
  public function damage(shot:Shot):Void {
    if(_state != State.Normal) {
      // すでにバステなら何もしない
      return;
    }

    _state = State.Sleep;
    _tBadstatus = TIMER_SLEEP;
    color = FlxColor.AZURE;
    _view.visible = false;
    moves = false;
    Snd.playSe("badstatus");
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _balloon.kill();
    _view.kill();
    super.kill();
  }

  /**
   * 消滅
   **/
  public function vanihs():Void {
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.LIME);
    kill();
  }

  function _awake():Void {
    moves = true;
    _state = State.Normal;
    _view.visible = true;
    color = FlxColor.LIME;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
    _updateBalloon();

    switch(_state) {
      case State.Normal:
        _updateMain();
      case State.Sleep:
        _tBadstatus--;
        if(_tBadstatus < 1) {
          // 復帰
          _awake();
        }
    }

    if(isOutside()) {
      // 画面外に出た
      kill();
    }

    if(x < 32 || FlxG.width-32 < x) {
      // FIXME: たまに画面外に登場するので消す
      kill();
    }
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    _updateView();

    // AIの実行
    _ai();

    if(_findTarget()) {
      // プレイヤー発見
      color = FlxColor.RED;
      _bFindTarget = true;
    }
    else {
      color = FlxColor.LIME;
    }

  }

  /**
   * 移動方向に向かって旋回する
   **/
  function _turn():Void {
    var next = DirUtil.toAngle(_dir);
    var d = MyMath.deltaAngle(_direction, next);
    var max = MAX_TURN_ANGLE;
    if(d > max) {
      d = max;
    }
    else if(d < -max) {
      d = -max;
    }
    _direction += d;
  }

  /**
   * AIの実行
   **/
  function _ai():Void {

    _timer++;
    switch(_type) {
      case EnemyType.RollCW:
        _direction += _rollSpeed;
      case EnemyType.RollCCW:
        _direction -= _rollSpeed;
      case EnemyType.Horizontal:
        if(_timer%TIMER_BACK == 0) {
          _dir = DirUtil.invert(_dir);
          _moveDirection();
        }
        _turn();

      case EnemyType.Vertical:
        if(_timer%TIMER_BACK == 0) {
          _dir = DirUtil.invert(_dir);
          _moveDirection();
        }
        _turn();
    }
  }

  /**
   * 視野の作成
   **/
  function _createView():Void {
    // 視野角度
    var deg:Float = _viewAngle;
    _view.revive();
    _balloon.revive();
    _balloon.visible = false;
    var array = new Array<FlxPoint>();
    var px:Float = _view.width/2;  // 中心(X)
    var py:Float = _view.height/2; // 中心(Y)
    var x1 = px + _viewDistance * MyMath.cosEx(deg);
    var y1 = py + _viewDistance * -MyMath.sinEx(deg);
    var x2 = px + _viewDistance * MyMath.cosEx(-deg);
    var y2 = py + _viewDistance * -MyMath.sinEx(-deg);
    array.push(FlxPoint.get(px, py));
    array.push(FlxPoint.get(x1, y1));
    array.push(FlxPoint.get(x2, y2));
    FlxSpriteUtil.fill(_view, FlxColor.TRANSPARENT);
    FlxSpriteUtil.drawPolygon(_view, array, FlxColor.WHITE);
    for(pt in array) {
      pt.put();
    }
  }

  /**
   * 視界の更新
   **/
  function _updateView():Void {
    _view.x = xcenter - _view.width/2;
    _view.y = ycenter - _view.height/2;

    // FlxSprite.angle は逆回り
    _view.angle = 360 - _direction;
  }

  /**
   * 吹き出しの更新
   **/
  function _updateBalloon():Void {
    _balloon.x = xcenter;
    _balloon.y = y - _balloon.height;

    _balloon.visible = (_state != State.Normal);
  }

  /**
   * プレイヤーを見つけたかどうか
   **/
  function _findTarget():Bool {
    if(FlxMath.isDistanceWithin(this, _target, _viewDistance) == false) {
      // 一定の距離内に存在しない
      return false;
    }

    var x1 = xcenter;
    var y1 = ycenter;
    var x2 = _target.xcenter;
    var y2 = _target.ycenter;

    if(MyMath.checkView(x1, y1, _direction, _viewDistance, _viewAngle, x2, y2) == false) {
      // 視界外
      return false;
    }
    if(Field.isHit(x1, y1, x2, y2)) {
      // 壁がある
      return false;
    }

    // 視界内
    return true;
  }

}
