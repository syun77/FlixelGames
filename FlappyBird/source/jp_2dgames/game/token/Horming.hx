package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.addons.effects.FlxTrail;

/**
 * ホーミング弾
 **/
class Horming extends Token {

  // 消滅タイマー
  static inline var TIMER_DESTROY:Int = 2 * 60;

  // 標的
  static var _target:Token = null;

  public static var parent:TokenMgr<Horming> = null;
  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr<Horming>(128, Horming);
    for(h in parent.members) {
      state.add(h.trail);
    }
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(attr:Attribute, X:Float, Y:Float, deg:Float):Horming {
    var horming = parent.recycle();
    horming.init(attr, X, Y, deg);
    return horming;
  }
  public static function setTarget(target:Token):Void {
    _target = target;
  }

  // --------------------------------------------
  // ■フィールド
  var _attr:Attribute;
  var _trail:FlxTrail;
  var _tDestroy:Int; // 消滅タイマー
  var _deg:Float; // 移動方向
  var _speed:Float; // 移動速度
  var _dRot:Float; // 旋回速度

  public var trail(get, never):FlxTrail;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BULLET, true);
    animation.add("play", [0, 1], 4);
    animation.play("play");
    _trail = new FlxTrail(this, null, 3, 1);
    alpha = 0.5;
    kill();
  }

  /**
   * 初期化
   **/
  public function init(attr:Attribute, X:Float, Y:Float, deg:Float):Void {
    _attr = attr;
    x = X - width/2;
    y = Y - height/2;
    _deg = deg;
    _speed = 200;
    _trail.revive();
    _trail.resetTrail();
    _tDestroy = TIMER_DESTROY;
    _dRot = 5;

    setVelocity(_deg, _speed);
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    super.kill();
    _trail.kill();
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.WHITE);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 旋回
    _turn();

    _tDestroy--;
    if(_tDestroy < 1) {
      // 消滅
      vanish();
    }
  }

  /**
   * 旋回
   **/
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



  // -------------------------------------------------
  // ■アクセサ
  function get_trail() {
    return _trail;
  }
}
