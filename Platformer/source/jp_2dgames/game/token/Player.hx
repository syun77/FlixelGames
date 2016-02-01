package jp_2dgames.game.token;

import flixel.FlxObject;
import flixel.FlxG;
import jp_2dgames.lib.Input;

/**
 * アニメーション状態
 **/
private enum AnimState {
  Standby; // 待機
  Run;     // 走り
  Jump;    // ジャンプ中
}

/**
 * プレイヤー
 **/
class Player extends Token {

  // 速度制限
  static inline var MAX_VELOCITY_X:Int = 80;
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

  // ======================================
  // ■メンバ変数
  var _anim:AnimState;
  var _animPrev:AnimState;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic("assets/images/player.png", true);
    // アニメーション登録
    _registerAnim();
    _playAnim(AnimState.Standby);

    // 変数初期化
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
    FlxG.watch.add(this.velocity, "y");
  }

  public override function update():Void {

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
      // 待機状態
      _anim = AnimState.Standby;
    }
    if(isTouching(FlxObject.FLOOR)) {
      // 地面に着地している
      if(Input.press.A) {
        // ジャンプ
        velocity.y = JUMP_VELOCITY;
      }
    }
    else {
      _anim = AnimState.Jump;
    }

    if(_anim != _animPrev) {
      // アニメーション変更
      _playAnim(_anim);
    }
    _animPrev = _anim;

    // 速度設定後に更新しないとめり込む
    super.update();
  }

  function _registerAnim():Void {
    animation.add('${AnimState.Standby}', [0, 0, 1, 0, 0], 4);
    animation.add('${AnimState.Run}', [2, 3], 8);
    animation.add('${AnimState.Jump}', [2], 1);
  }

  function _playAnim(anim:AnimState):Void {
    animation.play('${anim}');
  }
}
