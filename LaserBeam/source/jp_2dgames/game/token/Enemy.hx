package jp_2dgames.game.token;

import jp_2dgames.lib.MyShake;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  Main;
  Hit;
  HitWait;
  Vanish;
}

/**
 * 敵
 **/
class Enemy extends Token {

  static inline var TIMER_HIT:Int = 40;

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, deg:Float, speed:Float):Enemy {
    var e = parent.recycle(Enemy);
    e.init(X, Y, deg, speed);
    return e;
  }
  public static function countExists():Int {
    return parent.countLiving();
  }
  public static function countHit():Int {
    var ret:Int = 0;
    parent.forEachAlive(function(e:Enemy) {
      if(e._state == State.Hit) {
        ret++;
      }
    });
    return ret;
  }
  public static function requestVanish():Void {
    parent.forEachAlive(function(e:Enemy) {
      if(e._state == State.HitWait) {
        e.vanish();
      }
    });
  }

  // -----------------------------------------------------------
  // ■フィールド
  var _state:State;
  var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, deg:Float, speed:Float):Void {
    x = X;
    y = Y;
    makeGraphic(32, 32, FlxColor.LIME);
    setVelocity(deg, speed);

    _state = State.Main;
    _timer = 0;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.LIME);
    MyShake.middle();
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Main:
      case State.Hit:
        _timer--;
        if(_timer < 1) {
          _state = State.HitWait;
        }
      case State.HitWait:
      case State.Vanish:
    }
  }

  public function hit():Void {
    _state = State.Hit;
    _timer = TIMER_HIT;
  }
}
