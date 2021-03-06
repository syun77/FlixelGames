package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import flixel.FlxObject;
import openfl.display.BlendMode;
import jp_2dgames.lib.DirUtil;
import flixel.addons.effects.FlxTrail;
import flixel.FlxSprite;

/**
 * アニメーション状態
 **/
private enum AnimState {
  Standby; // 待機
  Run;     // 走り
  Brake;   // ブレーキ
  Jump;    // ジャンプ中
  Damage;  // ダメージ
}

private enum State {
  Standing; // 地面に立っている
  Jumping;  // 空中にいる
}

/**
 * プレイヤー
 **/
class Player extends Token {

  // 速度制限
  static inline var MAX_VELOCITY_X:Int = 70;
  //static inline var MAX_VELOCITY_Y:Int = 330;
  static inline var MAX_VELOCITY_Y:Int = 165;
  // 重力
//  static inline var GRAVITY:Int = 400;
  static inline var GRAVITY:Int = 200;
  // 移動量の減衰値
  static inline var DRAG_X:Int = MAX_VELOCITY_X * 4;
  static inline var DRAG_DASH:Int = DRAG_X * 2;
  // 移動加速度
  static inline var ACCELERATION_LEFT:Int = -MAX_VELOCITY_X * 4;
  static inline var ACCELERATION_RIGHT:Int = -ACCELERATION_LEFT;
  // ジャンプの速度
//  static inline var JUMP_VELOCITY:Float = -MAX_VELOCITY_Y / 2;
  static inline var JUMP_VELOCITY:Float = -MAX_VELOCITY_Y * 0.75;
  // 空中ダッシュの速度
  static inline var AIRDASH_VELOCITY:Float = MAX_VELOCITY_X * 4;

  // ----------------------------------------
  // ■タイマー
  static inline var TIMER_JUMPDOWN:Int   = 12; // 飛び降り

  // ----------------------------------------

  // ======================================
  // ■メンバ変数
  var _state:State; // キャラクター状態
  var _anim:AnimState; // アニメーション状態

  var _tAnim:Int = 0;
  var _timer:Int;
  var _animPrev:AnimState;
  var _light:FlxSprite;
  var _trail:FlxTrail;
  var _tJumpDown:Int = 0; // 飛び降りタイマー
  var _dir:Dir; // 向いている方向

  var _gravityDirection:Float = 1.0; // 重力の方向
  var _bInvertGravity:Bool = false; // 着地までに重力反転を使用したかどうか

  // キー入力
  var _inputJump(get, never):Bool;
  var _inputGravity(get, never):Bool;

  /**
   * 飛び降り中かどうか
   **/
  public function isJumpDown():Bool {
    return _tJumpDown > 0;
  }

  public function getLight():FlxSprite {
    return _light;
  }
  public function getTrail():FlxTrail {
    return _trail;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    // アニメーション登録
    _registerAnim();
    _playAnim(AnimState.Standby);

    // トレイル
    _trail = new FlxTrail(this, null, 5);

    // 明かり
    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);

    // 変数初期化
    _state = State.Jumping;
    _timer = 0;
    _anim = AnimState.Standby;
    _animPrev = AnimState.Standby;
    _dir = Dir.Right;

    // ■移動パラメータ設定
    // 速度制限を設定
    maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
    // 重力を設定
    _setGravity();
    // 移動量の減衰値を設定
    drag.x = DRAG_X;

    // 当たり判定を小さくする
    width = 8;
    offset.x = 4;

    // デバッグ
    FlxG.watch.add(this, "_state", "Player.state");
    FlxG.watch.add(this, "_anim", "Player.anim");
  }

  /**
   * 重力を設定
   **/
  function _setGravity():Void {
    // 重力加速度を設定
    acceleration.y = GRAVITY;
    acceleration.y *= _gravityDirection;
  }

  /**
   * ジャンプ速度を設定
   **/
  function _setJumpVelocity():Void {
    velocity.y = JUMP_VELOCITY;
    velocity.y *= _gravityDirection;
    Snd.playSe("jump");

    // 着地したことにする
    _bInvertGravity = false;
  }

  /**
   * 重力方向を反転する
   **/
  function _invertGravityDirection():Void {
    _gravityDirection *= -1;
    _setGravity();

    // 上下反転
    flipY = (_gravityDirection < 0);

    // 一方通行床のコリジョンを反転
    Floor.reverseAll();

    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.WHITE);

    Snd.playSe("shot");
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {

    // 入力方向を更新
    var dir = DirUtil.getInputDirection();
    if(dir != Dir.None) {
      _dir = dir;
    }

    if(moves) {
      // 入力更新
      _input();
    }

    // アニメーション更新
    if(_anim != _animPrev) {
      // アニメーション変更
      _playAnim(_anim);
      _animPrev = _anim;
    }

    // タイマー更新
    _updateTimer();

    // 速度設定後に更新しないとめり込む
    super.update(elapsed);

    acceleration.x *= 0.9;

    // ライト更新
    _updateLight();

  }

  /**
   * 床に着地しているかどうか
   **/
  function _isTouchingFloor():Bool {
    if(_gravityDirection < 0) {
      return isTouching(FlxObject.CEILING);
    }
    else {
      return isTouching(FlxObject.FLOOR);
    }
  }

  function _input():Void {

    // キャラクター状態
    switch(_state) {
      case State.Standing:
        // 左右に移動
        _moveLR();
        if(_isTouchingFloor()) {
          velocity.y = 0;
        }
        if(Input.on.DOWN) {
          // 飛び降りる
          _tJumpDown = TIMER_JUMPDOWN;
        }
        else if(_inputJump) {
          // ジャンプ
          _setJumpVelocity();
        }

        if(_isTouchingFloor() == false) {
          // ジャンプした
          _state = State.Jumping;
        }
      case State.Jumping:
        // 左右に移動
        _moveLR();

        _anim = AnimState.Jump;
        if(_isTouchingFloor()) {
          // 着地した
          _state = State.Standing;
        }
    }

    if(_inputGravity) {
      if(_bInvertGravity == false) {
        // 重力反転を実行
        _invertGravityDirection();
        _bInvertGravity = true;
      }
    }
  }

  /**
   * 各種タイマーの更新
   **/
  function _updateTimer():Void {

    // アニメタイマー更新
    _tAnim++;

    // 飛び降りタイマー更新
    if(_tJumpDown > 0) {
      _tJumpDown--;
    }
  }

  /**
   * 光源の更新
   **/
  function _updateLight():Void {
    var sc = FlxG.random.float(0.7, 1);
    _light.scale.set(sc, sc);
    _light.alpha = FlxG.random.float(0.2, 0.3);
    _light.x = xcenter;
    _light.y = ycenter;
  }

  /**
   * 左右に移動する
   **/
  function _moveLR():Void {
    acceleration.x = 0;
    if(Input.on.LEFT) {
      // 左に移動
      acceleration.x = ACCELERATION_LEFT;
      _anim = AnimState.Run;
      flipX = true;
    }
    else if(Input.on.RIGHT) {
      // 右に移動
      acceleration.x = ACCELERATION_RIGHT;
      _anim = AnimState.Run;
      flipX = false;
    }
    else {
      if(Math.abs(velocity.x) > 0.001) {
        // ブレーキ
        _anim = AnimState.Brake;
      }
      else {
        // 待機状態
        _anim = AnimState.Standby;
      }
    }

    // flipXをFlxTrailに反映
    for(spr in _trail.members) {
      spr.flipX = flipX;
    }
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, MyColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, MyColor.CRIMSON);
    kill();
    // トレイルも消す
    _trail.kill();
    // ライトも消す
    _light.kill();

  }

  /**
   * ダメージ処理
   **/
  public function damage():Void {
    /*
    // 死亡
    vanish();
    FlxG.camera.shake(0.05, 0.4);
    FlxG.camera.flash(FlxColor.WHITE, 0.5);
    */
    _anim = AnimState.Damage;
  }

  /**
   * ジャンプする
   **/
  public function jump():Void {
    _setJumpVelocity();
  }

  /**
   * ワープする
   **/
  public function warp(X:Float, Y:Float):Void {
    Particle.start(PType.Ball, xcenter, ycenter, MyColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, MyColor.CRIMSON);
    x = X;
    y = Y;
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${AnimState.Standby}', [0, 0, 1, 0, 0], 1);
    animation.add('${AnimState.Run}', [2, 2, 3, 3], 3);
    animation.add('${AnimState.Brake}', [4], 1);
    animation.add('${AnimState.Jump}', [2], 1);
    animation.add('${AnimState.Damage}', [5, 6], 2);
  }

  /**
   * アニメ再生
   **/
  function _playAnim(anim:AnimState):Void {
    animation.play('${anim}');
  }


  // -----------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 6;
  }
  function get__inputJump() {
    // ジャンプできないようにする
    return false;
//    return Input.press.B;
  }
  function get__inputGravity() {
    return Input.press.B;
  }
}
