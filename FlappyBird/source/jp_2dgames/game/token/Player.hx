package jp_2dgames.game.token;

import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.FlxG;
import jp_2dgames.lib.Input;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var SPEED_JUMP:Float = 200.0;
  static inline var GRAVITY:Float = 800.0;

  // ---------------------------------------------------------
  // ■フィールド
  var _attr:Attribute = Attribute.Red;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _playAnim();

    acceleration.y = GRAVITY;
    maxVelocity.set(SPEED_JUMP, SPEED_JUMP);
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(Input.press.B) {
      velocity.y = -SPEED_JUMP;
    }

    // 位置による死亡チェック
    _checkDead();
  }

  /**
   * 死亡チェック
   **/
  function _checkDead():Void {
    if(y < -height) {
      vanish();
    }
    if(y > FlxG.height) {
      vanish();
    }
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    animation.add('${Attribute.Red}', [0], 1);
    animation.add('${Attribute.Blue}', [1], 1);
  }

  /**
   * アニメ再生
   **/
  function _playAnim():Void {
    animation.play('${_attr}');
  }
}
