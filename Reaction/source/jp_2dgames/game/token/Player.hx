package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.global.Global;
import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.lib.MyMath;

/**
 * アニメ定数
 **/
private enum Anim {
  Standby; // 待機中
  Damage;  // ダメージを受けた
  Danger;  // 危険
}

/**
 * 状態
 **/
private enum State {
  Standby; // 待機中
  Damage;  // ダメージ中
}

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var RADIUS:Float = 12.0;
  static inline var REACT_SPEED:Float = 100.0;
  static inline var MAX_SPEED:Float = 500.0;
  static inline var DRAG_SPEED:Float = 100.0;

  static inline var TIMER_DAMAGE:Int = 60;
  static inline var DANGER_HP:Int = 40; // 危険状態とするHP
  static inline var AUTORECOVER_HP:Float = 5.0; // 自然回復するHPの量 (1秒あたり)

  // ----------------------------------
  // ■フィールド
  var _anim:Anim = Anim.Standby;
  var _state:State = State.Standby;
  var _cursor:Cursor;
  var _rot:Float; // カーソルがある方向
  var _timer:Int; // 汎用タイマー

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, cursor:Cursor) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _playAnim();

    maxVelocity.set(MAX_SPEED, MAX_SPEED);
    drag.set(DRAG_SPEED, DRAG_SPEED);

    _cursor = cursor;
    _rot = 0;
    _timer = 0;

    FlxG.watch.add(this, "_state", "player.state");
    FlxG.watch.add(this, "_anim", "player.anim");
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // ショットを撃つ
    if(Input.press.A) {
      _shot();
    }

    // 回転
    _rotate();

    // カベとの衝突で反動する
    _reflectWall();

    switch(_state) {
      case State.Standby:
        _updateStandby(elapsed);
      case State.Damage:
        _updateDamage();
    }
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    return Global.life < DANGER_HP;
  }

  // 更新・待機中
  function _updateStandby(elapsed:Float):Void {

    // HP自動回復
    Global.addLife(elapsed * AUTORECOVER_HP);

    if(isDanger()) {
      // 危険状態
      _anim = Anim.Danger;
    }
    else {
      _anim = Anim.Standby;
    }
    // アニメーション再生
    _playAnim();
  }
  // 更新・ダメージ中
  function _updateDamage():Void {
    _timer--;
    if(_timer < 1) {
      // ダメージ状態終了
      _state = State.Standby;
      _anim = Anim.Standby;
      _playAnim();
    }
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
    kill();
  }

  /**
   * ダメージを受ける
   **/
  public function damage(val:Int, ?obj:Token):Void {

    if(_state == State.Damage) {
      // ダメージ状態の場合は1ダメージだけ
      Global.subLife(1);
    }
    else {
      Global.subLife(val);
    }

    if(obj != null) {
      var dx = obj.xcenter - xcenter;
      var dy = obj.ycenter - ycenter;
      var deg = MyMath.atan2Ex(-dy, dx);
      setVelocity(deg-180, 100);
    }

    _anim  = Anim.Damage;
    _playAnim();
    // ダメージ状態
    _state = State.Damage;
    _timer = TIMER_DAMAGE;
  }

  /**
   * ショットを撃つ
   **/
  function _shot():Void {
    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var rot = MyMath.atan2Ex(-dy, dx);
    Shot.add(xcenter, ycenter, rot, 500);

    // 反動
    velocity.x -= REACT_SPEED * MyMath.cosEx(rot);
    velocity.y -= REACT_SPEED * -MyMath.sinEx(rot);
  }

  /**
   * 回転
   **/
  function _rotate():Void {
    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var rot = MyMath.atan2Ex(-dy, dx);
    var dRot = MyMath.deltaAngle(_rot, rot);
    _rot += dRot * 0.1;
    angle = 360 - _rot;
  }

  /**
   * カベとの衝突の反動
   **/
  function _reflectWall():Void {
    var x1 = 0;
    var y1 = 0;
    var x2 = FlxG.width - width;
    var y2 = FlxG.height - height;

    if(x < x1) {
      x = x1;
      velocity.x *= -1;
    }
    if(y < y1) {
      y = y1;
      velocity.y *= -1;
    }
    if(x > x2) {
      x = x2;
      velocity.x *= -1;
    }
    if(y > y2) {
      y = y2;
      velocity.y *= -1;
    }
  }

  /**
   * アニメーション再生
   **/
  function _playAnim():Void {
    animation.play('${_anim}');
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${Anim.Standby}', [0, 1], 2);
    animation.add('${Anim.Damage}',  [2],    1);
    animation.add('${Anim.Danger}',  [0, 2], 2);
  }

  // ------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return RADIUS;
  }

}
