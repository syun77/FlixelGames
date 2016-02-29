package jp_2dgames.game.token;
import jp_2dgames.game.token.Enemy.EnemyType;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var SPEED_DECAY:Float = 0.1 * 60;

  var _xtarget:Float;
  var _ytarget:Float;
  var _type:EnemyType = EnemyType.Blue;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(x, y);
    makeGraphic(16, 16, FlxColor.WHITE);

    _xtarget = x;
    _ytarget = y;

    _changeType();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _xtarget = Input.mouse.x - width/2;
    _ytarget = Input.mouse.y - height/2;

    var vx = (_xtarget - x) * SPEED_DECAY;
    var vy = (_ytarget - y) * SPEED_DECAY;
    velocity.set(vx, vy);

    if(Input.press.A) {
      // 色変え
      _changeType();
    }
  }

  function _changeType():Void {
    switch(_type) {
      case EnemyType.Red:   _type = EnemyType.Green;
      case EnemyType.Green: _type = EnemyType.Blue;
      case EnemyType.Blue:  _type = EnemyType.Red;
    }

    color = Enemy.typeToColor(_type);
  }
}
