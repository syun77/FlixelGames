package jp_2dgames.game.token;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.ParticleScore;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.lib.MyMath;
import jp_2dgames.lib.Input;

/**
 * 敵
 **/
class Enemy extends Token {

  static inline var TIMER_SHAKE:Int = 32;

  var _xbase:Float;
  var _ybase:Float;
  var _eid:Int = 0;
  var _tAnim:Int = 0;
  var _hp:Int;
  var _hpmax:Int;
  public var hp(get, never):Int;
  public var hpratio(get, never):Float;
  var _turn:Int;
  public var turn(get, never):Int;
  var _bAttack:Bool;
  public var isAttack(get, never):Bool;
  var _tShake:Int;
  var _bAppear:Bool;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    var sc = 0.1;
    scale.set(sc, sc);

    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 256, 256);
    _registerAnim();

    x -= width/2 * (1 - sc);
    y -= height/2 * (1 - sc);

    _xbase = x;
    _ybase = y;
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, hp:Int):Void {
    _eid = eid;
    _hp  = hp;
    _hpmax = hp;
    // ターン数設定
    _turn = Calc.Turn(_eid);
    _bAttack = false;

    _playAnim();
    _tShake = 0;

    // 出現演出
    x = _xbase + 64;
    FlxTween.tween(this, {x:_xbase}, 0.5, {ease:FlxEase.expoOut});
    _bAppear = true;
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Void {

    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    ParticleScore.start(xcenter, ycenter, v);
    _hp -= v;
    if(_hp <= 0) {
      // 倒した
      _hp = 0;
      Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
      var px = xcenter;
      var py = ycenter;
      new FlxTimer().start(0.1, function(timer:FlxTimer) {
        Particle.start(PType.Ring, px, py, FlxColor.WHITE);
      }, 1+_eid);

      FlxG.camera.shake(0.02, 0.3);

      // 次の敵登場
      x += 128;
      new FlxTimer().start(0.75, function(timer:FlxTimer) {
        _appearNext();
      });
    }
    else {
      _tShake = TIMER_SHAKE;
    }
  }

  function _appearNext():Void {
    _eid++;
    if(_eid >= 5) {
      _eid = 0;
    }

    // HPとターン数を設定
    init(_eid, 100);
  }

  /**
   * ターン経過
   * @param 攻撃する場合は true
   **/
  public function nextTurn(target:Player):Bool {

    if(_bAppear) {
      // 出現直後はターン数を減らさない
      _bAppear = false;
      return false;
    }

    _turn--;
    if(_turn <= 0) {
      // 攻撃開始
      _attack(target);
      return true;
    }

    return false;
  }

  /**
   * ターン数加算
   **/
  public function addTurn(v:Int):Void {
    _turn += v;
  }

  /**
   * 攻撃
   **/
  function _attack(target:Player):Void {

    // 攻撃開始
    _bAttack = true;

    // 移動速度
    var speed = 0.2;

    var xprev = x;
    var xtarget = x - 32;
    FlxTween.tween(this, {x:xtarget}, speed, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
      // ダメージを与える
      // TODO: シールドゲージ
      var v = Calc.Damage(_eid);
      target.damage(v);
      FlxTween.tween(this, {x:xprev}, speed, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
        // おしまい
        _bAttack = false;
        // ターン数を再設定
        _turn = Calc.Turn(_eid);
      }});
    }});
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

    angle = 15 * MyMath.sinEx(_tAnim*2);

    if(_tShake > 0) {
      _tShake--;
      var d = _tShake;
      if(_tShake%8 < 4) {
        d *= -1;
      }
      x = _xbase + d/8;
    }
  }

  function _playAnim():Void {
    animation.play('${_eid}');
  }

  function _registerAnim():Void {
    for(i in 0...5) {
      animation.add('${i}', [i], 1);
    }
  }

  // -----------------------------------------------------
  // ■アクセサ
  function get_hp() {
    return _hp;
  }
  function get_hpratio() {
    return _hp / _hpmax;
  }
  function get_turn() {
    return _turn;
  }
  function get_isAttack() {
    return _bAttack;
  }
}
