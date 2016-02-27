package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxRandom;
import openfl._legacy.display.BlendMode;
import flixel.FlxSprite;
import flixel.FlxG;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.Input;

/**
 * プレイヤー
 **/
class Player extends Token {

  // 無敵フラグ
  static inline var INVINCIBLE = false;

  // 移動速度
  static inline var MOVE_SPEED:Float = 300.0;

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

    // コリジョンサイズ調整
    width = 16;
    height = 16;
    offset.set(8, 8);

    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);
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
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.PINK);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.PINK);
    FlxG.camera.shake(0.05, 0.4);
    FlxG.camera.flash(FlxColor.WHITE, 0.5);
    kill();
    Snd.playSe("damage");
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
    _updateLight();
    if(_checkOutside()) {
      // 押しつぶされた
      vanish();
      return;
    }

    _clipScreen();
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
    if(dir == null) {
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
    if(Input.press.B == false) {
      // 撃たない
      return;
    }
    if(Shot.parent.countLiving() > 0) {
      // 撃てない
      return;
    }

    var angle = _dir;
    Shot.add(xcenter, ycenter, angle, 500);
    Snd.playSe("shot");
  }

  /**
   * 明かりを更新
   **/
  function _updateLight():Void {
    var sc = FlxRandom.floatRanged(0.7, 1) * 2;
    _light.scale.set(sc, sc);
    _light.alpha = FlxRandom.floatRanged(0.2, 0.3);
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
}
