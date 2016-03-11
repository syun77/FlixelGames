package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.ParticleScore;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.MyMath;
import flixel.math.FlxMath;
private enum State {
  Standby; // 待機
  Attack;  // 攻撃
  Damage;  // ダメージ
}

/**
 * プレイヤー
 **/
class Player extends Token {

  var _state:State;
  var _timer:Int;
  var _tAnim:Int;

  var _ybase:Float;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    var sc = 0.15;
    scale.set(sc, sc);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    x -= width / 2 * (1 - sc);
    y -= height / 2 * (1 - sc);
    _ybase = y;
    _registerAnim();

    _change(State.Standby);
    _timer = 0;
    _tAnim = 0;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

    y = _ybase + 1 * MyMath.sinEx(_tAnim*2);
  }

  /**
   * ダメージ処理
   **/
  public function damage(v:Int):Void {
    Global.subLife(v);
    ParticleScore.start(xcenter, ycenter, v);
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
  }

  /**
   * 状態遷移
   **/
  function _change(s:State):Void {
    _state = s;
    animation.play('${s}');
  }

  function _registerAnim():Void {
    animation.add('${State.Standby}', [1], 1);
    animation.add('${State.Attack}', [0], 1);
    animation.add('${State.Damage}', [2], 1);
  }
}
