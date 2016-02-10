package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import flixel.addons.effects.FlxTrail;
import flixel.util.FlxRandom;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;

/**
 * ホーミングショット
 **/
class Horming extends Token {

  // 消滅タイマー
  static inline var TIMER_DESTORY:Int = 2 * 60;

  public static var parent:TokenMgr<Horming> = null;

  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr(128, Horming);
    state.add(parent);

    parent.forEach(function(h:Horming) {
      state.add(h.getTrail());
    });
  }
  public static function destroyParent():Void {
    parent = null;
  }

  public static function add(target:Token, X:Float, Y:Float, deg:Float):Horming {
    var s:Horming = parent.recycle();
    s.init(target, X, Y, deg);
    return s;
  }

  public static function countExist():Int {
    return parent.countLiving();
  }

  // =========================================================================
  // ■メンバ変数
  var _trail:FlxTrail;
  var _tDestroy:Int;
  var _target:Token;
  var _deg:Float;
  var _speed:Float;
  var _dRot:Float; // 旋回速度

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHOT, true);
    animation.add("play", [0, 1], 8);
    animation.play("play");
    _trail = new FlxTrail(this);
    _trail.kill();
    kill();
  }
  public function getTrail():FlxTrail {
    return _trail;
  }

  /**
   * 初期化
   **/
  public function init(target:Token, X:Float, Y:Float, deg:Float):Void {
    x = X - width/2;
    y = Y - height/2;

    var speed = 200;
    deg += FlxRandom.floatRanged(-15, 15);
    setVelocity(deg, speed);

    _tDestroy = TIMER_DESTORY;
    _target = target;
    _deg = deg;
    _speed = speed;
    _dRot = 5;

    // トレイル再表示
    _trail.revive();
    _trail.resetTrail();

    Snd.playSe("shot");
  }

  /**
   * 更新
   **/
  public override function update():Void {
    super.update();
    // 旋回
    _turn();

    _tDestroy--;
    if(_tDestroy < 1) {
      // 消滅
      Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.LIME);
      kill();
    }

  }

  // 旋回
  function _turn():Void {
    if(_target == null) {
      return;
    }
    if(_target.exists == false) {
      // ターゲットが消滅した
      return;
    }
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    var aim = MyMath.atan2Ex(-dy, dx);
    var d = MyMath.deltaAngle(_deg, aim);
    var sign = if(d > 0) 1 else -1;
    _deg += _dRot * sign;
    _dRot += 0.1;
    _speed += 5;
    setVelocity(_deg, _speed);
  }

  override public function kill():Void {
    super.kill();
    _trail.kill();
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.AZURE);
    kill();
  }
}
