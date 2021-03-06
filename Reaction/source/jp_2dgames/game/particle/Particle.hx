package jp_2dgames.game.particle;

import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.math.FlxAngle;
import flash.display.BlendMode;
import flixel.FlxSprite;

/**
 * パーティクルの種類
 **/
enum PType {
  Ball;    // 玉
  Ball2;   // 玉2
  Spiral;  // らせん
  Ring;    // リング
  Ring2;   // リング2
  Ring3;   // リング3(逆再生)
}

/**
 * パーティクル
 **/
class Particle extends FlxSprite {

  static inline var SCALE_BASE:Float    = 2.0;
  static inline var SCALE_BALL:Float    = 0.25 * SCALE_BASE;
  static inline var SCALE_BALL2:Float   = 0.05 * SCALE_BASE;
  static inline var SCALE_SPIRAL:Float  = 0.25 * SCALE_BASE;
  static inline var SCALE_RING:Float    = 3 * SCALE_BASE;
  static inline var SCALE_RING2:Float   = 0.5 * SCALE_BASE;
  static inline var SCALE_RING3:Float   = 8 * SCALE_BASE;

  static inline var SPEED_RATIO:Float   = 0.5;

  // パーティクル管理
  public static var parent:FlxTypedGroup<Particle> = null;

  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Particle>(256);
    for(i in 0...parent.maxSize) {
      parent.add(new Particle());
    }
    state.add(parent);
  }

  /**
   * 消滅
   **/
  public static function destroyParent():Void {
    parent = null;
  }

  /**
   * 開始
   **/
  public static function start(type:PType, X:Float, Y:Float, color:Int=FlxColor.WHITE):Void {

    switch(type) {
      case PType.Ball:
        var dir = FlxG.random.float(0, 45);
        for(i in 0...8) {
          var p:Particle = parent.recycle();
          var spd = FlxG.random.float(100, 400) * SPEED_RATIO;
          var t = FlxG.random.int(40, 60);
          p.init(type, t, X, Y, dir, spd);
          p.color = color;
          dir += FlxG.random.float(40, 50);
        }
      case PType.Ball2:
        var dir = FlxG.random.float(0, 45);
        for(i in 0...8) {
          var p:Particle = parent.recycle();
          var spd = FlxG.random.float(100, 400) * SPEED_RATIO;
          var t = FlxG.random.int(10, 20);
          p.init(type, t, X, Y, dir, spd);
          p.color = color;
          dir += FlxG.random.float(40, 50);
        }
      case PType.Ring, PType.Ring2, PType.Ring3:
        var t = 60;
        var p:Particle = parent.recycle();
        p.init(type, t, X, Y, 0, 0);
        p.color = color;

      case PType.Spiral:
        var p:Particle = parent.recycle();
        var spd = FlxG.random.float(10, 20);
        var t = FlxG.random.int(40, 60);
        p.init(type, t, X, Y, 90, spd);
        p.color = color;
    }
  }

  // 種別
  private var _type:PType;
  // タイマー
  private var _timer:Int;
  // 開始タイマー
  private var _tStart:Int;
  // 拡張パラメータ
  private var _val:Float;
  // 最初のX座標
  private var _xprev:Float;

  /**
	 * コンストラクタ
	 **/

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_EFFECT, true);

    // アニメーション登録
    animation.add('${PType.Ball}', [0], 1);
    animation.add('${PType.Ball2}', [0], 1);
    animation.add('${PType.Ring}', [1], 2);
    animation.add('${PType.Ring2}', [1], 2);
    animation.add('${PType.Ring3}', [1], 2);
    animation.add('${PType.Spiral}', [0], 1);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // 加算ブレンド
    blend = BlendMode.ADD;

    // 非表示
    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:PType, timer:Int, X:Float, Y:Float, direction:Float, speed:Float):Void {
    _type = type;
    animation.play('${type}');
    _timer = timer;
    _tStart = timer;
    _val = 0;
    _xprev = X;

    // 座標と速度を設定
    x = X;
    y = Y;
    var rad = FlxAngle.asRadians(direction);
    velocity.x = Math.cos(rad) * speed;
    velocity.y = -Math.sin(rad) * speed;

    // 初期化
    alpha = 1.0;
    switch(_type) {
      case PType.Ball:
        var sc = SCALE_BALL;
        scale.set(sc, sc);
        acceleration.y = 300 * SPEED_RATIO;
      case PType.Ball2:
        var sc = SCALE_BALL2;
        scale.set(sc, sc);
        acceleration.y = 300 * SPEED_RATIO;
      case PType.Ring, PType.Ring2, PType.Ring3:
        scale.set(0, 0);
        acceleration.y = 0;
        alpha = _timer / _tStart;
      case PType.Spiral:
        var sc = SCALE_SPIRAL;
        scale.set(sc, sc);
        acceleration.y = -200;
        _val = FlxG.random.float() * 3.14*2;
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_type) {
      case PType.Ball, PType.Ball2:
        _timer--;
        velocity.x *= 0.95;
        velocity.y *= 0.95;
        scale.x *= 0.97;
        scale.y *= 0.97;
        alpha = FlxEase.expoOut(_timer / _tStart);
      case PType.Ring:
        _timer = Std.int(_timer * 0.93);
        var sc = SCALE_RING * (_tStart - _timer) / _tStart;
        scale.set(sc, sc);
        alpha = FlxEase.expoOut(_timer / _tStart);
      case PType.Ring2:
        _timer = Std.int(_timer * 0.93);
        var sc = SCALE_RING2 * (_tStart - _timer) / _tStart;
        scale.set(sc, sc);
        alpha = FlxEase.expoOut(_timer / _tStart);
      case PType.Ring3:
        _timer = Std.int(_timer * 0.93);
        var sc = SCALE_RING3 * _timer / _tStart;
        scale.set(sc, sc);
        alpha = FlxEase.expoOut(_timer / _tStart);
      case PType.Spiral:
        _timer--;
        _val += 0.05*2;
        if(_val > 3.14*2) {
          _val -= 3.14*2;
        }

        x = _xprev + 16 * Math.sin(_val);
        velocity.y *= 0.95;
        scale.x *= 0.97;
        scale.y *= 0.97;
    }

    if(_timer < 1) {
      // 消滅
      kill();
    }
  }
}
