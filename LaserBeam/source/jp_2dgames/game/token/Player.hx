package jp_2dgames.game.token;

import jp_2dgames.lib.MyShake;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import jp_2dgames.lib.MyMath;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
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

  // 移動速度
  static inline var MOVE_SPEED:Float = 300.0;

  static inline var TIMER_DESTROY:Int = 60;

  // カーソル
  var _cursor:Cursor;
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
  public function new(X:Float, Y:Float, cursor:Cursor) {
    super(X, Y);
    _cursor = cursor;

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

    // レーザー発射
    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var deg = MyMath.atan2Ex(-dy, dx);
    var x1 = xcenter;
    var y1 = ycenter;
    var x2 = xcenter + 800 * MyMath.cosEx(deg);
    var y2 = ycenter + 800 * -MyMath.sinEx(deg);
    Laser.init(x1, y1, x2, y2);
    _cursor.active = false;

    // 動けなくする
    moves = false;

    // 衝突判定
    _intersectLaser(x1, y1, x2, y2);

    // すべての敵の動きを止める
    Enemy.stopAll();

    // 敵弾の動きを止める
    Bullet.parent.active = false;
  }

  /**
   * レーザーと敵との衝突判定
   **/
  function _intersectLaser(x1:Float, y1:Float, x2:Float, y2:Float):Void {

    var cnt:Int = 0;

    var enemyList = Enemy.getSortedList();
    for(e in enemyList) {
      var rect = FlxRect.get(e.x, e.y, e.width, e.height);
      if(MyMath.intersectLineAndRect(x1, y1, x2, y2, rect)) {
        // 敵に命中
        new FlxTimer().start(cnt*0.1, function(timer:FlxTimer) {
          Particle.start(PType.Ring, e.xcenter, e.ycenter, FlxColor.RED);
          e.hit();
        });
        cnt++;
      }
      rect.put();
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
