package jp_2dgames.game.token;

import flixel.addons.effects.FlxTrail;
import jp_2dgames.game.global.Global;
import flixel.util.FlxRandom;
import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxMath;
import flixel.FlxObject;
import flixel.FlxG;
import jp_2dgames.lib.Input;

/**
 * アニメーション状態
 **/
private enum AnimState {
  Standby; // 待機
  Run;     // 走り
  Brake;   // ブレーキ
  Jump;    // ジャンプ中
  Damage;  // ダメージ中
}

private enum State {
  Normal; // 通常
  Damage; // ダメージ
}

/**
 * プレイヤー
 **/
class Player extends Token {

  // 速度制限
  static inline var MAX_VELOCITY_X:Int = 120;
  static inline var MAX_VELOCITY_Y:Int = 400;
  // 重力
  static inline var GRAVITY:Int = 400;
  // 移動量の減衰値
  static inline var DRAG_X:Int = MAX_VELOCITY_X * 4;
  // 移動加速度
  static inline var ACCELERATION_LEFT:Int = -MAX_VELOCITY_X * 4;
  static inline var ACCELERATION_RIGHT:Int = -ACCELERATION_LEFT;
  // ジャンプの速度
  static inline var JUMP_VELOCITY:Float = -MAX_VELOCITY_Y / 2;

  // ----------------------------------------
  // ■タイマー
  static inline var TIMER_DAMAGE:Int   = 30; // ダメージ
  static inline var TIMER_JUMPDOWN:Int = 12;  // 飛び降り

  // ======================================
  // ■メンバ変数
  var _state:State;
  var _timer:Int;
  var _anim:AnimState;
  var _animPrev:AnimState;
  var _light:FlxSprite;
  var _trail:FlxTrail;
  var _tJumpDown:Int; // 飛び降りタイマー

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

  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    // アニメーション登録
    _registerAnim();
    _playAnim(AnimState.Standby);

    // トレイル
    _trail = new FlxTrail(this, null, 3, 4);

    // 明かり
    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);

    // 変数初期化
    _state = State.Normal;
    _timer = 0;
    _anim = AnimState.Standby;
    _animPrev = AnimState.Standby;

    // ■移動パラメータ設定
    // 速度制限を設定
    maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
    // 重力加速度を設定
    acceleration.y = GRAVITY;
    // 移動量の減衰値を設定
    drag.x = DRAG_X;

    // デバッグ
    FlxG.watch.add(this.velocity, "y", "vy");
    FlxG.watch.add(this, "_state", "state");
  }

  /**
   * 更新
   **/
  public override function update():Void {

    switch(_state) {
      case State.Normal:
        // 移動できる
        _move();
        // ショット
        _shot();
        // 時間経過でライフ回復
        _regenerate();
      case State.Damage:
        // ダメージ中
        _updateDamage();
    }

    // 飛び降りタイマー更新
    if(_tJumpDown > 0) {
      _tJumpDown--;
    }

    // 速度設定後に更新しないとめり込む
    super.update();

    _updateLight();
  }

  /**
   * 光源の更新
   **/
  function _updateLight():Void {
    var sc = FlxRandom.floatRanged(0.7, 1);
    _light.scale.set(sc, sc);
    _light.alpha = FlxRandom.floatRanged(0.2, 0.3);
    _light.x = xcenter;
    _light.y = ycenter;
  }

  /**
   * ダメージの更新
   **/
  function _updateDamage():Void {
    _timer--;
    if(_timer < 1) {
      _state = State.Normal;
      _anim = AnimState.Standby;
      _playAnim(_anim);
    }
  }

  /**
   * 移動
   **/
  function _move():Void {
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
    if(isTouching(FlxObject.FLOOR)) {
      // 地面に着地している
      if(Input.on.DOWN && Input.press.A) {
        // 飛び降りる
        _tJumpDown = TIMER_JUMPDOWN;
      }
      else if(Input.press.A) {
        // ジャンプ
        velocity.y = JUMP_VELOCITY;
      }
    }
    else {
      _anim = AnimState.Jump;
    }

    if(_anim != _animPrev) {
      {
        // アニメーション変更
        _playAnim(_anim);
      }
      _animPrev = _anim;
    }
  }

  /**
   * ショット
   **/
  function _shot():Void {
  }

  /**
   * 時間経過によるライフ回復
   **/
  function _regenerate():Void {
    Global.addLife(0.05);
  }

  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.CRIMSON);
    kill();
  }

  /**
   * ダメージ処理
   **/
  public function damage(obj:FlxObject):Void {

    if(_state == State.Damage) {
      // ダメージ中は何もしない
      return;
    }

    // ダメージ中でなければHPを減らす
    if(Global.subLife(40)) {
      // 死亡
      vanish();
      FlxG.camera.shake(0.05, 0.4);
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
    }
    else {
      FlxG.camera.shake(0.01, 0.2);
    }

    // 移動値と重力を無効
    acceleration.x = 0;
    velocity.y = 0;

    var dx = x - obj.x;
    velocity.x = MAX_VELOCITY_X * 8 * FlxMath.signOf(dx);
    _state = State.Damage;
    _timer = TIMER_DAMAGE;
    _playAnim(AnimState.Damage);
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${AnimState.Standby}', [0, 0, 1, 0, 0], 4);
    animation.add('${AnimState.Run}', [2, 3], 8);
    animation.add('${AnimState.Brake}', [4], 1);
    animation.add('${AnimState.Jump}', [2], 1);
    animation.add('${AnimState.Damage}', [5, 6], 20);
  }

  /**
   * アニメ再生
   **/
  function _playAnim(anim:AnimState):Void {
    animation.play('${anim}');
  }
}
