package jp_2dgames.game.token;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import openfl.display.BlendMode;
import flixel.FlxSprite;
import flixel.FlxG;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.Input;

/**
 * プレイヤー
 **/
class Player extends Token {

  // 無敵フラグ
  public static inline var INVINCIBLE = false;

  // 斜め移動を許可するかどうか
  static inline var ENABLE_DIAGONAL:Bool = false;

  // 移動速度
  static inline var MOVE_SPEED:Float = 200.0;

  static inline var TIMER_DESTROY:Int = 60;

  // 向き
  var _dir:Float = 0.0;
  // 歩いているかどうか
  var _bWalk:Bool;
  // 明かり
  var _light:FlxSprite;
  public var light(get, never):FlxSprite;
  var _tDestroy:Int = -1;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _dir = -90;
    _bWalk = false;
    _playAnim();

    /*
    // コリジョンサイズ調整
    width = 16;
    height = 16;
    offset.set(8, 8);
    */

    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);

    FlxG.watch.add(this, "x", "player.x");
    FlxG.watch.add(this, "y", "player.y");
  }

  public function requestDestroy():Void {
    _tDestroy = TIMER_DESTROY;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    if(INVINCIBLE) {
      // 無敵
      return;
    }

    // 死亡
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.PINK);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.PINK);

    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
    _updateLight();
    if(_checkOutside()) {
      // 押しつぶされた
      vanish();
      return;
    }

    if(moves == false) {
      // 動けない
      return;
    }

//    _clipScreen();
    _move();
    _shot();

    if(_tDestroy > 0) {
      _tDestroy--;
      visible = (_tDestroy%8 < 4);
      if(_tDestroy < 1) {
        vanish();
      }
    }
  }

  function _checkOutside():Bool {
    var bottom = FlxG.camera.scroll.y + FlxG.height;
    if(y > bottom) {
      // 画面外
      return true;
    }

    return false;
  }

  /**
   * 画面内に入るようにする
   **/
  function _clipScreen():Void {
    var left = 0;
    var right = FlxG.width - width;
    if(x < left) {
      x = left;
    }
    if(x > right) {
      x = right;
    }
    var top = FlxG.camera.scroll.y;
    var bottom = FlxG.camera.scroll.y + FlxG.height - height - 16;
    if(y < top) {
      y = top;
    }
    if(y > bottom) {
      y = bottom;
    }
  }

  /**
   * 移動する
   **/
  function _move():Void {
    velocity.set();
    var dir = DirUtil.getInputAngle();
    if(dir == -1000) {
      // 動いていない
      _bWalk = false;
      return;
    }
    _dir = dir;
    var deg = _dir;
    setVelocity(deg, MOVE_SPEED);

    // 動いているフラグを立てる
    _bWalk = true;

    // アニメ再生
    _playAnim();
  }

  function _shot():Void {
    if(moves == false) {
      // 撃てない
      return;
    }
    if(Input.press.A == false) {
      // 撃たない
      return;
    }
  }

  /**
   * 明かりを更新
   **/
  function _updateLight():Void {
    var sc = FlxG.random.float(0.7, 1) * 2;
    _light.scale.set(sc, sc);
    _light.alpha = FlxG.random.float(0.2, 0.3);
    _light.x = xcenter;
    _light.y = ycenter;

  }

  /**
   * アニメーション再生
   **/
  function _playAnim():Void {
    var func = function() {
      switch(Std.int(_dir)) {
        case 0: return Dir.Right;
        case 45, 90, 135: return Dir.Up;
        case 180: return Dir.Left;
        case 225, 270, 315: return Dir.Down;
        default: return Dir.Down;
      }
    }
    var dir = func();
    animation.play('${dir}${_bWalk}');
  }

  /**
   * アニメーションを登録
   **/
  function _registerAnim():Void {
    var spd:Int = 2;
    var bWalk:Bool = false;
    animation.add('${Dir.Left}${bWalk}', [0, 1], spd);
    animation.add('${Dir.Up}${bWalk}', [4, 5], spd);
    animation.add('${Dir.Right}${bWalk}', [8, 9], spd);
    animation.add('${Dir.Down}${bWalk}', [12, 13], spd);

    spd = 6;
    bWalk = true;
    animation.add('${Dir.Left}${bWalk}', [2, 3], spd);
    animation.add('${Dir.Up}${bWalk}', [6, 7], spd);
    animation.add('${Dir.Right}${bWalk}', [10, 11], spd);
    animation.add('${Dir.Down}${bWalk}', [14, 15], spd);
  }

  function get_light() {
    return _light;
  }


  // --------------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 16;
  }

}
