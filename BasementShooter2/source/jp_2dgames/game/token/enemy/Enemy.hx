package jp_2dgames.game.token.enemy;
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
  Skull; // ドクロ
}

/**
 * 敵
 **/
class Enemy extends Token {

  // 重力
  public static inline var GRAVITY:Int = 400;

  // ターゲットとの距離の種別
  public static inline var DIST_NEAR:Int = 0; // 近い
  public static inline var DIST_MID:Int  = 1; // 中間
  public static inline var DIST_FAR:Int  = 2; // 遠い

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
  var _hp:Int;
  var _xrection:Float;
  var _yrection:Float;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 16, 16);
    animation.add('${EnemyType.Goast}', [0,  1],  4);
    animation.add('${EnemyType.Bat}',   [4,  5],  4);
    animation.add('${EnemyType.Snake}', [8,  9],  4);
    animation.add('${EnemyType.Skull}', [12, 13], 4);

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
    _xrection = 0;
    _yrection = 0;

    animation.play('${_type}');
    flipX = false;
    drag.set();
    acceleration.set();

    switch(_type) {
      case EnemyType.Bat:
        _ai = new EnemyBat(this);
        _hp = 5;
      case EnemyType.Goast:
        _ai = new EnemyGoast(this);
        _hp = 5;
      case EnemyType.Snake:
        _ai = new EnemySnake(this);
        _hp = 10;
      case EnemyType.Skull:
        _ai = new EnemySkull(this);
        _hp = 20;
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
  public function damage(v:Int, token:Token):Void {
    _hp -= v;
    if(_hp < 1) {
      vanish();
    }

    var dx = token.velocity.x;
    var dy = token.velocity.y;
    var deg = MyMath.atan2Ex(-dy, dx);
    var spd = 10;
    _xrection = spd * MyMath.cosEx(deg);
    _yrection = spd * -MyMath.sinEx(deg);
  }

  /**
   * 弾を撃つ
   **/
  public function bullet(deg:Float, speed:Float):Void {
    if(isOutside()) {
      // 画面外からは撃てない
      return;
    }

    bulletOfs(0, 0, deg, speed);
  }
  public function bulletOfs(ofsX:Float, ofsY:Float, deg:Float, speed:Float):Void {
    var px = xcenter + ofsX;
    var py = ycenter + ofsY;
    Bullet.add(px, py, deg, speed);
  }

  /**
   * 更新
   **/
  public override function update():Void {

    if(_ai != null) {
      _ai.proc();
      _ai.move(this);
      if(isOnScreen()) {
        _ai.attack(this);
      }
    }

    velocity.x += _xrection;
    velocity.y += _yrection;
    _xrection *= 0.7;
    _yrection *= 0.7;

    super.update();
  }

  /**
   * ターゲットへの角度を取得
   **/
  public function getAim(ofsX:Float=0.0, ofsY:Float=0.0):Float {
    var dx = _target.xcenter - (xcenter + ofsX);
    var dy = _target.ycenter - (ycenter + ofsY);
    return MyMath.atan2Ex(-dy, dx);
  }

  /**
   * ターゲットへの距離種別を取得
   **/
  public function getDistType():Int {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    var dist = Math.sqrt(dx*dx + dy*dy);
    if(dist > 200) {
      // 長距離
      return DIST_FAR;
    }
    if(dist < 100) {
      // 近距離
      return DIST_NEAR;
    }
    // 中間
    return DIST_MID;
  }
}
