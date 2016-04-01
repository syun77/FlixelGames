package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.FlxG;
import jp_2dgames.lib.Input;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var SPEED_JUMP:Float = 200.0;
  static inline var GRAVITY:Float = 800.0;

  // ---------------------------------------------------------
  // ■フィールド
  var _barrier:Barrier;
  var _attr:Attribute = Attribute.Red;
  var _cntHorming:Int = 0; // ホーミング発射量
  var _tHorming:Int = 0; // ホーミング発射のインターバル

  public var attribute(get, null):Attribute;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, barrier:Barrier) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _playAnim();

    _barrier = barrier;
    _barrier.setCenter(xcenter, ycenter);
    _barrier.change(_attr);

    acceleration.y = GRAVITY;
    maxVelocity.set(SPEED_JUMP, SPEED_JUMP);
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    super.kill();
    _barrier.kill();
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    var color = AttributeUtil.toColor(_attr);
    Particle.start(PType.Ball, xcenter, ycenter, color);
    Particle.start(PType.Ring, xcenter, ycenter, color);

    kill();

    Snd.playSe("explosion", true);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // バリア座標更新
    _barrier.setCenter(xcenter, ycenter);

    if(Input.press.B) {
      // ジャンプ
      velocity.y = -SPEED_JUMP;

      Snd.playSe("jump2", true);
    }
    if(Input.press.X) {
      // 属性チェンジ
      _attr = AttributeUtil.invert(_attr);
      Particle.start(PType.Ring, xcenter, ycenter, AttributeUtil.toColor(_attr));
      _playAnim();
      _barrier.change(_attr);

      // ゲージ量に合わせてホーミング発射開始
      _cntHorming = Std.int(_calcCountHorming());
      // ホーミングゲージをゼロにする
      Global.subShot(100);

      Snd.playSe("change", true);
    }

    if(_cntHorming > 0) {
      if(_tHorming > 0) {
        _tHorming--;
      }
      else {
        // ホーミング発射
        var cnt = Std.int(_cntHorming / 4);
        if(cnt < 1) { cnt = 1; }
        for(i in 0...cnt) {
          Horming.add(_attr, xcenter, ycenter, FlxG.random.float(135, 225));
          _cntHorming--;
          Snd.playSe("goal", true);
        }
        _tHorming = 1;
      }
    }

    // 位置による死亡チェック
    _checkDead();
  }

  /**
   * ゲージの量に合わせてホーミング弾を発射
   **/
  function _calcCountHorming():Int {
    var v = Global.shot;
    if(v < 1) { return 0; }
    if(v < 5) { return 1; }
    if(v < 10) { return 2; } // +4
    if(v < 20) { return 7; } // +10
    if(v < 30) { return 13; } // +12
    if(v < 40) { return 22; } // +18
    if(v < 50) { return 35; } // +25
    if(v < 60) { return 49; } // +28
    if(v < 70) { return 64; } // +30
    if(v < 80) { return 80; } // +32
    if(v < 90) { return 92; } // +36
    return 128;
  }

  /**
   * 死亡チェック
   **/
  function _checkDead():Void {
    if(y < -height) {
      vanish();
    }
    if(y > FlxG.height) {
      vanish();
    }
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    animation.add('${Attribute.Red}', [1], 1);
    animation.add('${Attribute.Blue}', [0], 1);
  }

  /**
   * アニメ再生
   **/
  function _playAnim():Void {
    animation.play('${_attr}');
  }

  // ----------------------------------------------------
  // ■アクセサ
  function get_attribute() {
    return _attr;
  }

  override public function get_radius():Float {
    return 6;
  }
}
