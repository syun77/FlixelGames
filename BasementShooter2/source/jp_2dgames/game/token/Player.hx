package jp_2dgames.game.token;

import jp_2dgames.game.token.enemy.EnemyMgr;
import jp_2dgames.game.token.enemy.Enemy;
import jp_2dgames.lib.MyMath;
import jp_2dgames.lib.DirUtil;
import flixel.addons.effects.FlxTrail;
import jp_2dgames.game.global.Global;
import flixel.util.FlxRandom;
import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxMath;
import flixel.FlxObject;
import flixel.FlxG;
import jp_2dgames.lib.Input;

/**
 * アニメーション状態
 **/
private enum AnimState {
  Standby; // 待機
  Run;     // 走り
  Brake;   // ブレーキ
  Jump;    // ジャンプ中
  Damage;  // ダメージ中
}

/**
 * コンディション
 **/
private enum ConditionState {
  None; // なし
  Damage; // ダメージ中
}

private enum State {
  Standing; // 地面に立っている
  Jumping;  // 空中にいる
  Airdashing;  // 空中ダッシュ中
}

/**
 * プレイヤー
 **/
class Player extends Token {

  // 速度制限
  static inline var MAX_VELOCITY_X:Int = 120;
  static inline var MAX_VELOCITY_Y:Int = 400;
  // 重力
  static inline var GRAVITY:Int = 400;
  // 移動量の減衰値
  static inline var DRAG_X:Int = MAX_VELOCITY_X * 4;
  static inline var DRAG_DASH:Int = DRAG_X * 2;
  // 移動加速度
  static inline var ACCELERATION_LEFT:Int = -MAX_VELOCITY_X * 4;
  static inline var ACCELERATION_RIGHT:Int = -ACCELERATION_LEFT;
  // ジャンプの速度
  static inline var JUMP_VELOCITY:Float = -MAX_VELOCITY_Y / 2;
  // 空中ダッシュの速度
  static inline var AIRDASH_VELOCITY:Float = MAX_VELOCITY_X * 4;
  // 反動
  static inline var REACTION_SPEED:Float = 10.0;
  static inline var REACTION_DECAY:Float = 0.7;

  // ----------------------------------------
  // ■タイマー
  static inline var TIMER_DAMAGE:Int   = 30; // ダメージ
  static inline var TIMER_JUMPDOWN:Int = 12; // 飛び降り
  static inline var TIMER_SHOT:Int     = 3; // ショット間隔
  static inline var TIMER_DASH:Int     = 10; // ダッシュ

  // ======================================
  // ■メンバ変数
  var _state:State; // キャラクター状態
  var _condition:ConditionState; // コンディション
  var _anim:AnimState; // アニメーション状態

  var _timer:Int;
  var _animPrev:AnimState;
  var _light:FlxSprite;
  var _trail:FlxTrail;
  var _shield:Shield;
  var _tJumpDown:Int; // 飛び降りタイマー
  var _dir:Dir; // 向いている方向
  var _tShot:Int; // ショットタイマー
  var _tDash:Int; // ダッシュタイマー
  var _bDash:Bool; // 空中ダッシュが可能かどうか
  var _tCondition:Int; // コンディションタイマー

  // 反動
  var _xreaction:Float = 0.0;
  var _yreaction:Float = 0.0;

  /**
   * 飛び降り中かどうか
   **/
  public function isJumpDown():Bool {
    return _tJumpDown > 0;
  }

  public function getLight():FlxSprite {
    return _light;
  }
  public function getTrail():FlxTrail {
    return _trail;
  }
  public function getShield():Shield {
    return _shield;
  }
  public function getShieldSpr():FlxSprite {
    return _shield.getSpr();
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    // アニメーション登録
    _registerAnim();
    _playAnim(AnimState.Standby);

    // トレイル
    _trail = new FlxTrail(this, null, 5);

    // 明かり
    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);

    // シールド
    _shield = new Shield();

    // 変数初期化
    _state = State.Jumping;
    _condition = ConditionState.None;
    _timer = 0;
    _anim = AnimState.Standby;
    _animPrev = AnimState.Standby;
    _dir = Dir.Right;
    _tShot = 0;
    _tDash = 0;
    _bDash = false;
    _tCondition = 0;

    // ■移動パラメータ設定
    // 速度制限を設定
    maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
    // 重力加速度を設定
    acceleration.y = GRAVITY;
    // 移動量の減衰値を設定
    drag.x = DRAG_X;

    // デバッグ
    FlxG.watch.add(this, "_state", "player.state");
    FlxG.watch.add(this, "x", "player.x");
    FlxG.watch.add(this, "y", "player.y");
  }

  /**
   * 更新
   **/
  public override function update():Void {

    // 入力方向を更新
    var dir = DirUtil.getInputDirectionOn(true);
    if(dir != Dir.None) {
      _dir = dir;
    }

    // 入力更新
    _input();
    if(_condition == ConditionState.Damage) {
      // ダメージ中はダメージアニメ
      _anim = AnimState.Damage;
    }

    // アニメーション更新
    if(_anim != _animPrev) {
      // アニメーション変更
      _playAnim(_anim);
      _animPrev = _anim;
    }
    // ショット
    _shot();
    // シールド
    _execShield();

    // コンディション
    switch(_condition) {
      case ConditionState.None:
        // 時間経過でライフ回復
        _regenerate();
      case ConditionState.Damage:
        // ダメージ中
        _updateDamage();
    }

    // タイマー更新
    _updateTimer();

    // 反動更新
    _updateReaction();

    // 速度設定後に更新しないとめり込む
    super.update();

    // ライト更新
    _updateLight();

    // シールド更新
    _updateShield();
  }

  function _input():Void {
    // キャラクター状態
    switch(_state) {
      case State.Standing:
        // 左右に移動
        _moveLR();
        _bDash = true; // ダッシュ可能
        if(Input.on.DOWN && Input.press.B) {
          // 飛び降りる
          _tJumpDown = TIMER_JUMPDOWN;
        }
        else if(Input.press.B) {
          // ジャンプ
          velocity.y = JUMP_VELOCITY;
        }

        if(isTouching(FlxObject.FLOOR) == false) {
          // ジャンプした
          _state = State.Jumping;
        }
      case State.Jumping:
        // 左右に移動
        _moveLR();
        _anim = AnimState.Jump;
        if(_bDash) {
          if(Input.press.B) {
            // 空中ダッシュ開始
            var dir = DirUtil.getInputDirectionOn(true);
            if(dir == Dir.None) {
              // 入力していない場合は上
              dir = Dir.Up;
            }
            var deg = DirUtil.toDegree(dir);
            var spd = AIRDASH_VELOCITY;
            var dx = MyMath.cosEx(deg) * spd;
            var dy = -MyMath.sinEx(deg) * spd;
            acceleration.set();
            velocity.set(dx, dy);
            _bDash = false;
            _tDash = TIMER_DASH;
            _state = State.Airdashing;
            maxVelocity.set(AIRDASH_VELOCITY, MAX_VELOCITY_Y);
            return;
          }
        }
        if(isTouching(FlxObject.FLOOR)) {
          // 着地した
          _state = State.Standing;
        }
      case State.Airdashing:
        // 空中ダッシュ中
        Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
        _tDash--;
        acceleration.y = GRAVITY;
        drag.set(DRAG_X, 0);
        if(isTouching(FlxObject.FLOOR)) {
          // 着地した
          _state = State.Standing;
          maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
        }
        else if(_tDash < 1) {
          // 空中ダッシュ終わり
          _state = State.Jumping;
          maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
        }
        else {
          // 継続中
          acceleration.set();
          drag.set(DRAG_DASH, DRAG_DASH*2);
        }
    }
  }

  /**
   * 各種タイマーの更新
   **/
  function _updateTimer():Void {
    // 飛び降りタイマー更新
    if(_tJumpDown > 0) {
      _tJumpDown--;
    }
    // ショットタイマー更新
    if(_tShot > 0) {
      _tShot--;
    }
  }

  /**
   * 反動の更新
   **/
  function _updateReaction():Void {
    velocity.x += _xreaction;
    velocity.y += _yreaction;
    _xreaction *= REACTION_DECAY;
    _yreaction *= REACTION_DECAY;
  }

  /**
   * 光源の更新
   **/
  function _updateLight():Void {
    var sc = FlxRandom.floatRanged(0.7, 1);
    _light.scale.set(sc, sc);
    _light.alpha = FlxRandom.floatRanged(0.2, 0.3);
    _light.x = xcenter;
    _light.y = ycenter;
  }

  /**
   * ダメージの更新
   **/
  function _updateDamage():Void {
    _tCondition--;
    if(_tCondition < 1) {
      _condition = ConditionState.None;
    }
  }

  function _updateShield():Void {
    _shield.x = xcenter - _shield.width/2;
    _shield.y = ycenter - _shield.height/2;
  }

  /**
   * 左右に移動する
   **/
  function _moveLR():Void {
    acceleration.x = 0;
    if(Input.on.LEFT) {
      // 左に移動
      acceleration.x = ACCELERATION_LEFT;
      _anim = AnimState.Run;
      flipX = true;
    }
    else if(Input.on.RIGHT) {
      // 右に移動
      acceleration.x = ACCELERATION_RIGHT;
      _anim = AnimState.Run;
      flipX = false;
    }
    else {
      if(Math.abs(velocity.x) > 0.001) {
        // ブレーキ
        _anim = AnimState.Brake;
      }
      else {
        // 待機状態
        _anim = AnimState.Standby;
      }
    }

    // flipXをFlxTrailに反映
    for(spr in _trail.members) {
      spr.flipX = flipX;
    }
  }

  /**
   * ショット
   **/
  function _shot():Void {
    if(Input.on.X == false) {
      // 撃たない
      return;
    }

    if(_tShot > 0) {
      // 撃てない
      return;
    }

    // 発射
    var speed = 300;
    var deg = DirUtil.toDegree(_dir);
    deg += FlxRandom.floatRanged(-3, 3); // 少しばらける
    Shot.add(xcenter, ycenter, deg, speed);
    _tShot = TIMER_SHOT;
  }

  /**
   * シールド
   **/
  function _execShield():Void {

    if(Input.on.X == false) {
      // 使わない
      return;
    }
    // シールドエネルギー減少
    _shield.subPower();

    if(_shield.isEnable() == false) {
      // 使えない
      return;
    }

    var e:Enemy = EnemyMgr.bosses.getFirstAlive();
    if(e == null) {
      e = EnemyMgr.enemies.getFirstAlive();
    }
    Bullet.forEachExists(function(b:Bullet) {
      var dist = FlxMath.distanceBetween(this, b);
      if(dist > _shield.radius) {
        // 範囲外
        return;
      }
      b.vanish();
      var vx = b.velocity.x;
      var vy = b.velocity.y;
      var deg = MyMath.atan2Ex(-vy, vx);
      Horming.add(e, b.xcenter, b.ycenter, deg);
      _xreaction += REACTION_SPEED * MyMath.cosEx(deg);
      _yreaction += REACTION_SPEED * -MyMath.sinEx(deg);
    });

  }

  /**
   * 時間経過によるライフ回復
   **/
  function _regenerate():Void {
    Global.addLife(0.05);
  }

  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.CRIMSON);
    kill();
    // トレイルも消す
    _trail.kill();
    // ライトも消す
    _light.kill();
    // シールドも消す
    _shield.kill();
  }

  /**
   * ダメージ処理
   **/
  public function damage(obj:FlxObject):Void {

    if(_condition == ConditionState.Damage) {
      // ダメージ中は何もしない
      return;
    }

    // ダメージ中でなければHPを減らす
    if(Global.subLife(40)) {
      // 死亡
      vanish();
      FlxG.camera.shake(0.05, 0.4);
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
    }
    else {
      FlxG.camera.shake(0.01, 0.2);
    }

    // 移動値と重力を無効
    acceleration.x = 0;
    velocity.y = 0;

    var dx = x - obj.x;
    velocity.x = MAX_VELOCITY_X * 8 * FlxMath.signOf(dx);
    _condition = ConditionState.Damage;
    _tCondition = TIMER_DAMAGE;
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${AnimState.Standby}', [0, 0, 1, 0, 0], 4);
    animation.add('${AnimState.Run}', [2, 3], 8);
    animation.add('${AnimState.Brake}', [4], 1);
    animation.add('${AnimState.Jump}', [2], 1);
    animation.add('${AnimState.Damage}', [5, 6], 20);
  }

  /**
   * アニメ再生
   **/
  function _playAnim(anim:AnimState):Void {
    animation.play('${anim}');
  }
}
