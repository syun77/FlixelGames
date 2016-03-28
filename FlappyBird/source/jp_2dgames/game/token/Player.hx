package jp_2dgames.game.token;

import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var SPEED_JUMP:Float = 200.0;
  static inline var GRAVITY:Float = 800.0;

  // ---------------------------------------------------------
  // ■フィールド


  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    makeGraphic(16, 16, FlxColor.BLUE);

    acceleration.y = GRAVITY;
    maxVelocity.set(SPEED_JUMP, SPEED_JUMP);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(Input.press.B) {
      velocity.y = -SPEED_JUMP;
    }
  }
}
