package jp_2dgames.game.token;

import flixel.FlxG;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

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

  public function new(X:Float, Y:Float) {
    super(X, Y);
    makeGraphic(16, 16, FlxColor.CRIMSON);

    // 速度制限を設定
    maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
    // 重力加速度を設定
    acceleration.y = GRAVITY;
    // 移動量の減衰値を設定
    drag.x = DRAG_X;

    FlxG.watch.add(this.velocity, "y");
  }

  public override function update():Void {

    acceleration.x = 0;
    if(Input.on.LEFT) {
      // 左に移動
      acceleration.x = ACCELERATION_LEFT;
    }
    else if(Input.on.RIGHT) {
      // 右に移動
      acceleration.x = ACCELERATION_RIGHT;
    }
    if(Input.press.A) {
      // ジャンプ
      velocity.y = JUMP_VELOCITY;
    }

    super.update();
  }
}
