package jp_2dgames.game.token;
import jp_2dgames.game.global.Global;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;
import flixel.FlxState;

/**
 * 敵の種類
 **/
enum EnemyType {
  Bat;   // コウモリ
  Goast; // ゴースト
  Snake; // ヘビ
}

/**
 * 敵
 **/
class Enemy extends Token {

  // 重力
  public static inline var GRAVITY:Int = 400;

  public static var parent:TokenMgr<Enemy> = null;
  static var _target:Player = null;

  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr(64, Enemy);
    state.add(parent);
  }

  public static function destroyParent():Void {
    parent = null;
  }

  public static function add(type:EnemyType, X:Float, Y:Float):Enemy {
    var e:Enemy = parent.recycle();
    e.init(type, X, Y);
    return e;
  }

  public static function setTarget(player:Player):Void {
    _target = player;
  }

  // =======================================
  // ■メンバ変数
  var _type:EnemyType;
  var _timer:Int;
  var _ai:EnemyAI;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 16, 16);
    animation.add('${EnemyType.Goast}', [0, 1], 4);
    animation.add('${EnemyType.Bat}',   [4, 5], 4);
    animation.add('${EnemyType.Snake}', [8, 9], 4);

    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _type = type;
    _timer = 0;

    animation.play('${_type}');
    flipX = false;
    acceleration.set();
    switch(_type) {
      case EnemyType.Bat:
        _ai = new EnemyBat(this);
      case EnemyType.Goast:
        _ai = new EnemyGoast(this);
      case EnemyType.Snake:
        _ai = new EnemySnake(this);
    }
  }

  /**
   * 敵を倒した
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);

    Global.addScore(200);

    FlxG.camera.shake(0.01, 0.2);
    kill();

    _ai = null;
  }

  /**
   * 敵へのダメージ
   **/
  public function damage(v:Int):Void {
    vanish();
  }

  /**
   * 弾を撃つ
   **/
  public function bullet(deg:Float, speed:Float):Void {
    if(isOutside()) {
      // 画面外からは撃てない
      return;
    }

    Bullet.add(xcenter, ycenter, deg, speed);
  }

  /**
   * 更新
   **/
  public override function update():Void {

    if(isOnScreen()) {
      if(_ai != null) {
        _ai.proc();
        _ai.move(this);
        _ai.attack(this);
      }
    }

    super.update();
  }

  public function getAim():Float {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    return MyMath.atan2Ex(-dy, dx);
  }
}
