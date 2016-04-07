package jp_2dgames.game.token;

import jp_2dgames.lib.StatusBar;
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

  static inline var TIMER_SHOT:Float = 0.8; // 0.8秒かかる
  static inline var SHOT_CHARGE:Float = 30.0; // 1秒あたりに回復量
  static inline var SHOT_DECREASE:Float = 5.0;

  static inline var RADIUS:Float = 12.0;
  static inline var REACT_SPEED:Float = 100.0;
  static inline var MAX_SPEED:Float = 500.0;
  static inline var DRAG_SPEED:Float = 200.0;

  static inline var TIMER_DAMAGE:Int = 60;
  static inline var DANGER_HP:Int = 40; // 危険状態とするHP
  static inline var AUTORECOVER_HP:Float = 5.0; // 自然回復するHPの量 (1秒あたり)
  static inline var WALL_ELASTICITY:Float = 1.5; // 外周のカベにぶつかったときの弾力性

  // ----------------------------------
  // ■フィールド
  var _anim:Anim = Anim.Standby;
  var _state:State = State.Standby;
  var _cursor:Cursor;
  var _rot:Float; // カーソルがある方向
  var _timer:Int; // 汎用タイマー
  var _hpbar:StatusBar; // HPゲージ
  var _tShot:Float; // ショットタイマー

  public var hpbar(get, never):StatusBar;

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

    _hpbar = new StatusBar(x, y, Std.int(width), 4);
    _hpbar.visible = false;

    FlxG.watch.add(this, "_state", "player.state");
    FlxG.watch.add(this, "_anim", "player.anim");
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_tShot > 0) {
      _tShot -= elapsed;
    }
    if(Input.on.A) {
      // ショットを撃つ
      _shot();
    }
    else {
      // ショットゲージ上昇
      Global.addShot(SHOT_CHARGE * elapsed);
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

    // HPゲージの更新
    updateHpBar();
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    return Global.life < DANGER_HP;
  }

  /**
   * HPゲージの更新
   **/
  public function updateHpBar():Void {
    _hpbar.visible = false;
    if(Global.life < Global.MAX_LIFE) {
      // HPが減少していたらHPゲージを表示
      _hpbar.visible = true;
      _hpbar.setPercent(Global.life);
      _hpbar.x = x;
      _hpbar.y = y + height;
    }
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
    _hpbar.kill();
    /*
  function _choice(level:Int):Int {
    if(level < 3) {
      return 1;
    }
    var func = function():Array<Int> {
      if(level%7 == 0) {
        return [1];
      }
      if(level%13 == 0) {
        return [2];
      }
      return [1, 2];
    }
    var arr = func();

    var idx = FlxG.random.int(0, arr.length-1);
    return arr[idx];
  }
  */

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
    if(_tShot > 0) {
      // 撃てない
      return;
    }

    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var rot = MyMath.atan2Ex(-dy, dx);
    var spd = 1000;
    Shot.add(xcenter, ycenter, rot, spd);
    Shot.add(xcenter, ycenter, rot-5, spd);
    Shot.add(xcenter, ycenter, rot+5, spd);

    // 反動
    velocity.x -= REACT_SPEED * MyMath.cosEx(rot);
    velocity.y -= REACT_SPEED * -MyMath.sinEx(rot);


    _tShot = TIMER_SHOT;
    var shot = Global.shot;
    if(shot > 1) {
      shot /= 10;
      if(shot > 1) {
        _tShot /= shot;
      }
      Global.subShot(SHOT_DECREASE);
    }
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
      velocity.x *= -WALL_ELASTICITY;
    }
    if(y < y1) {
      y = y1;
      velocity.y *= -WALL_ELASTICITY;
    }
    if(x > x2) {
      x = x2;
      velocity.x *= -WALL_ELASTICITY;
    }
    if(y > y2) {
      y = y2;
      velocity.y *= -WALL_ELASTICITY;
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
  function get_hpbar() {
    return _hpbar;
  }

}
