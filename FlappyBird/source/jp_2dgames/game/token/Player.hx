package jp_2dgames.game.token;

import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.particle.Particle;
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
  public var attribute(get, null):Attribute;

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

    var color = AttributeUtil.toColor(_attr);
    Particle.start(PType.Ball, xcenter, ycenter, color);
    Particle.start(PType.Ring, xcenter, ycenter, color);

    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(Input.press.B) {
      // ジャンプ
      velocity.y = -SPEED_JUMP;
    }
    if(Input.press.X) {
      // 属性チェンジ
      _attr = AttributeUtil.invert(_attr);
      Particle.start(PType.Ring, xcenter, ycenter, AttributeUtil.toColor(_attr));
      _playAnim();
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
    animation.add('${Attribute.Red}', [1], 1);
    animation.add('${Attribute.Blue}', [0], 1);
  }

  /**
   * アニメ再生
   **/
  function _playAnim():Void {
    animation.play('${_attr}');
  }

  // ----------------------------------------------------
  // ■アクセサ
  function get_attribute() {
    return _attr;
  }

  override public function get_radius():Float {
    return 4;
  }
}
