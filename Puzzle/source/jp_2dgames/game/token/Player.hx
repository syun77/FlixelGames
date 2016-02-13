package jp_2dgames.game.token;

import jp_2dgames.game.global.Global;
import jp_2dgames.lib.DirUtil;
import flixel.addons.effects.FlxTrail;
import flixel.util.FlxRandom;
import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxObject;
import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.lib.Snd;

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

private enum State {
  Standing; // 地面に立っている
  Jumping;  // 空中にいる
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
  static inline var TIMER_DAMAGE:Int     = 30; // ダメージ
  static inline var TIMER_INVINCIBLE:Int = 60; // 無敵点滅中
  static inline var TIMER_JUMPDOWN:Int   = 12; // 飛び降り
  static inline var TIMER_SHOT:Int       = 3; // ショット間隔
  static inline var TIMER_DASH:Int       = 10; // ダッシュ

  // ----------------------------------------
  // ■ショットに必要なパワー
  static inline var SHOT_POWER:Float = 40.0;

  // ======================================
  // ■メンバ変数
  var _state:State; // キャラクター状態
  var _anim:AnimState; // アニメーション状態

  var _tAnim:Int = 0;
  var _timer:Int;
  var _animPrev:AnimState;
  var _light:FlxSprite;
  var _trail:FlxTrail;
  var _tJumpDown:Int; // 飛び降りタイマー
  var _dir:Dir; // 向いている方向

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

    // 変数初期化
    _state = State.Jumping;
    _timer = 0;
    _anim = AnimState.Standby;
    _animPrev = AnimState.Standby;
    _dir = Dir.Right;

    // ■移動パラメータ設定
    // 速度制限を設定
    maxVelocity.set(MAX_VELOCITY_X, MAX_VELOCITY_Y);
    // 重力加速度を設定
    acceleration.y = GRAVITY;
    // 移動量の減衰値を設定
    drag.x = DRAG_X;

    moves = false;
    mass = 1;
    width = 8;
    offset.x = 4;

    // デバッグ
    FlxG.watch.add(this, "_state", "player.state");
    FlxG.watch.add(this, "x", "player.x");
    FlxG.watch.add(this, "y", "player.y");
    FlxG.watch.add(this.velocity, "x", "player.vy");
    FlxG.watch.add(this.velocity, "y", "player.vy");
  }

  /**
   * 更新
   **/
  public override function update():Void {

    // 入力方向を更新
    if(Input.on.UP) {
      // 上に撃つ
      _dir = Dir.Up;
    }
    else {
      if(flipX) {
        _dir = Dir.Left;
      }
      else {
        _dir = Dir.Right;
      }
    }

    // 入力更新
    _input();

    // アニメーション更新
    if(_anim != _animPrev) {
      // アニメーション変更
      _playAnim(_anim);
      _animPrev = _anim;
    }
    // ショット
    _shot();

    // タイマー更新
    _updateTimer();

    // 速度設定後に更新しないとめり込む
    super.update();

    updateMotionY();
    FlxG.overlap(this, Block.parent, function(player:Player, block:Block) {
      if(y < block.y) {
        // 上から衝突
        y = Std.int(block.y - height - 1);
        _state = State.Standing;
        touching = FlxObject.FLOOR;
        velocity.y = 0;
      }
      else {
//        y = Std.int(block.y + block.height);
        // 下からぶつかったら死亡
        damage();
      }
    });
    updateMotionX();
    FlxG.overlap(this, Block.parent, function(player:Player, block:Block) {
      if(x < block.x) {
        // 左側から衝突
        x = Std.int(block.x - width);
      }
      else {
        x = Std.int(block.x + block.width);
      }
      velocity.x = 0;
    });

    // ライト更新
    _updateLight();

    // ショットゲージ増加
    var prev = Global.getShot();
    Global.addShot(0.1);
    if(Global.getShot() >= SHOT_POWER) {
      if(prev < SHOT_POWER) {
        Snd.playSe("ready");
      }
      if(_tAnim%16 == 0) {
        Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.WHITE);
      }
    }

  }

  function _input():Void {
    // キャラクター状態
    switch(_state) {
      case State.Standing:
        // 左右に移動
        _moveLR();
        if(Input.on.DOWN && Input.press.B) {
          // 飛び降りる
          _tJumpDown = TIMER_JUMPDOWN;
        }
        else if(Input.press.B) {
          // ジャンプ
          velocity.y = JUMP_VELOCITY;
          _state = State.Jumping;
          Snd.playSe("jump");
        }

        /*
        if(isTouching(FlxObject.FLOOR) == false) {
          // ジャンプした
          _state = State.Jumping;
        }
        */
      case State.Jumping:
        // 左右に移動
        _moveLR();
        _anim = AnimState.Jump;
        if(isTouching(FlxObject.FLOOR)) {
          // 着地した
          _state = State.Standing;
        }
    }
  }

  /**
   * 各種タイマーの更新
   **/
  function _updateTimer():Void {

    // アニメタイマー更新
    _tAnim++;

    // 飛び降りタイマー更新
    if(_tJumpDown > 0) {
      _tJumpDown--;
    }
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
    if(Input.press.X == false) {
      // 撃たない
      return;
    }

    if(Global.getShot() < SHOT_POWER) {
      // 撃てない
      return;
    }

    Global.subShot(SHOT_POWER);

    // 発射
    var speed = 200;
    var deg = DirUtil.toDegree(_dir);
    Shot.add(xcenter, ycenter, deg, speed);
    Snd.playSe("shot");
  }

  override public function kill():Void {
    super.kill();
    // トレイルも消す
    _trail.kill();
    // ライトも消す
    _light.kill();
  }


  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.CRIMSON);
    kill();

    Snd.playSe("explosion");
    Snd.stopMusic();
  }

  /**
   * ダメージ処理
   **/
  public function damage():Void {
    // 死亡
    vanish();
    FlxG.camera.shake(0.05, 0.4);
    FlxG.camera.flash(FlxColor.WHITE, 0.5);
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
