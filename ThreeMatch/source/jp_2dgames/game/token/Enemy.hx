package jp_2dgames.game.token;

/**
 * 敵
 **/
import jp_2dgames.game.global.Global;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.lib.MyMath;
import jp_2dgames.lib.Input;
class Enemy extends Token {

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

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    var sc = 0.15/2;
    scale.set(sc, sc);

    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 256, 256);
    _registerAnim();

    x -= width/2 * (1 - sc);
    y -= height/2 * (1 - sc);
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, hp:Int):Void {
    _eid = eid;
    _hp  = hp;
    _hpmax = hp;
    // TODO: ターン数設定
    _turn = 3;
    _bAttack = false;

    _playAnim();
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Void {
    _hp -= v;
    if(_hp < 0) {
      _hp = 0;
    }
  }

  /**
   * ターン経過
   * @param 攻撃する場合は true
   **/
  public function nextTurn():Bool {
    _turn--;
    if(_turn <= 0) {
      // 攻撃開始
      _attack();
      return true;
    }

    return false;
  }

  /**
   * 攻撃
   **/
  function _attack():Void {

    // 攻撃開始
    _bAttack = true;

    // 移動速度
    var speed = 0.2;

    var xprev = x;
    var xtarget = x - 32;
    FlxTween.tween(this, {x:xtarget}, speed, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
      // ダメージを与える
      var v = 20; // TODO: ダメージ値
      Global.subLife(v);
      FlxTween.tween(this, {x:xprev}, speed, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
        // おしまい
        _bAttack = false;
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

    if(Input.press.X) {
      _eid++;
      if(_eid >= 5) {
        _eid = 0;
      }
      _playAnim();
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
