package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import flixel.FlxG;
import jp_2dgames.game.token.EnemyAI;
import jp_2dgames.lib.MyMath;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.MyShake;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ds.ArraySort;

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
  static var _target:Player;
  public static function setTarget(target:Player):Void {
    _target = target;
  }

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Enemy {
    var e = parent.recycle(Enemy);
    e.init(eid, X, Y, deg, speed);
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

  public static function getSortedList():Array<Enemy> {
    var ret = new Array<Enemy>();
    parent.forEachAlive(function(e:Enemy) {
      var dx = e.xcenter - _target.xcenter;
      var dy = e.ycenter - _target.ycenter;
      e._distance = dx*dx + dy*dy;
      ret.push(e);
    });

    ArraySort.sort(ret, function(e1:Enemy, e2:Enemy) {
      return Std.int(e1._distance - e2._distance);
    });
    return ret;
  }

  /**
   * すべての敵の動きを止める
   **/
  public static function stopAll():Void {
    parent.forEachAlive(function(e:Enemy) {
      e.moves = false;
    });
  }

  // -----------------------------------------------------------
  // ■フィールド
  var _eid:Int;
  var _state:State;
  var _timer:Int;
  var _ai:EnemyAI;
  var _decay:Float = 1.0; // 移動の減衰値
  var _bReflect:Bool; // 画面端で跳ね返るかどうか
  var _distance:Float;


  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Void {
    _eid = eid;
    x = X;
    y = Y;
    var radius = EnemyInfo.getRadius(_eid);
    makeGraphic(radius, radius, FlxColor.WHITE);
    color = FlxColor.LIME;
    setVelocity(deg, speed);

    _state = State.Main;
    _timer = 0;
    _decay = 1.0;
    _bReflect = true; // デフォルトで反射有効
    _distance = 9999999;

    // AI読み込み
    {
      var script = EnemyInfo.getAI(_eid);
      _ai = new EnemyAI(this, AssetPaths.getAIScript(script));
    }
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.LIME);
    MyShake.middle();
    kill();

    Snd.playSe("damage", true);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Main:
        _updateMain(elapsed);
      case State.Hit:
        color = FlxColor.interpolate(FlxColor.LIME, FlxColor.WHITE, _timer/TIMER_HIT);
        var xrnd = _timer/TIMER_HIT*3;
        var yrnd = _timer/TIMER_HIT*3;
        x = xstart + FlxG.random.float(-xrnd, xrnd);
        y = ystart + FlxG.random.float(-yrnd, yrnd);
        _timer--;
        if(_timer < 1) {
          _state = State.HitWait;
        }
      case State.HitWait:
      case State.Vanish:
    }
  }

  /**
   * 更新・メイン
   **/
  function _updateMain(elapsed:Float):Void {
    _ai.exec(elapsed);
    velocity.x *= _decay;
    velocity.y *= _decay;

    if(_bReflect) {
      // 反射あり
      _reflect();
    }
  }

  /**
   * 減衰値を設定する
   **/
  public function setDecay(decay:Float):Void {
    _decay = decay;
  }

  public function hit():Void {
    _state = State.Hit;
    _timer = TIMER_HIT;
    xstart = x;
    ystart = y;
  }
  /**
   * 弾を撃つ
   **/
  public function bullet(deg:Float, speed:Float):Void {
    bullet2(0, 0, deg, speed);
  }
  public function bullet2(xofs:Float, yofs:Float, deg:Float, speed:Float):Void {
    var px = xcenter + xofs;
    var py = ycenter + yofs;
    Bullet.add(px, py, deg, speed);
  }

  /**
   * 画面端反射フラグを設定する
   **/
  public function setReflect(b:Bool):Void {
    _bReflect = b;
  }

  /**
   * 狙い撃ち角度の取得
   **/
  public function getAim():Float {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    return MyMath.atan2Ex(-dy, dx);
  }

  /**
   * 画面外で跳ね返る
   **/
  function _reflect():Void {
    if(x < 0) {
      x = 0;
      velocity.x *= -1;
    }
    if(y < 0) {
      y = 0;
      velocity.y *= -1;
    }
    var x2 = FlxG.width - width;
    var y2 = FlxG.height - height;
    if(x > x2) {
      x = x2;
      velocity.x *= -1;
    }
    if(y > y2) {
      y = y2;
      velocity.y *= -1;
    }
  }

  // ------------------------------------------------------------
  // ■アクセサ

  /*
  override public function get_xcenter():Float {
    return x + width/2;
  }

  override public function get_ycenter():Float {
    return y + height/2;
  }
  */


}
