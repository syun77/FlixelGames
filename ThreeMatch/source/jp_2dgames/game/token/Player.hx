package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import jp_2dgames.lib.StatusBar;
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

  static inline var TIMER_DAMAGE:Int = 32;
  static inline var TIMER_ATTACK:Int = 16;

  var _state:State;
  var _timer:Int;
  var _tAnim:Int;

  var _xbase:Float;
  var _ybase:Float;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    var sc = 1;
    scale.set(sc, sc);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    x -= width / 2 * (1 - sc);
    y -= height / 2 * (1 - sc);
    _xbase = x;
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

    switch(_state) {
      case State.Standby:
        y = _ybase + 1 * MyMath.sinEx(_tAnim*2);
      case State.Attack:
        x = _xbase + 4;
        _timer--;
        if(_timer < 1) {
          x = _xbase;
          _change(State.Standby);
        }
      case State.Damage:
        _timer--;
        var d = _timer;
        if(d%8 < 4) {
          d *= -1;
        }
        x = _xbase + d/8;
        if(_timer < 1) {
          x = _xbase;
          _change(State.Standby);
        }
    }
  }

  public function attack():Void {
    _timer = TIMER_ATTACK;
    _change(State.Attack);
  }

  /**
   * ダメージ処理
   **/
  public function damage(v:Int):Void {
    Snd.playSe("hit");
    Global.subLife(v);
    ParticleScore.start(xcenter, ycenter, v);
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    _timer = TIMER_DAMAGE;
    _change(State.Damage);

    var intensity = 0.01 + 0.03 * v / 100;

    FlxG.camera.shake(intensity, 0.2);

    if(Global.life <= 0) {
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
      kill();
      Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
      Snd.playSe("explosion");
    }
  }

  /**
   * HP回復
   **/
  public function recover(v:Int):Void {
    Global.addLife(v);
    ParticleScore.start(xcenter, ycenter, v, FlxColor.LIME);
  }

  /**
   * 状態遷移
   **/
  function _change(s:State):Void {
    _state = s;
    animation.play('${s}');
  }

  function _registerAnim():Void {
    animation.add('${State.Standby}', [0, 0, 0, 0, 1], 4);
    animation.add('${State.Attack}', [4], 1);
    animation.add('${State.Damage}', [5, 6], 16);
  }
}
