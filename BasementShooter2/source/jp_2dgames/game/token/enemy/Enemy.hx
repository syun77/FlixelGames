package jp_2dgames.game.token.enemy;
import jp_2dgames.game.global.Global;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;

/**
 * 敵の種類
 **/
enum EnemyType {
  None;
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

  static var _target:Player = null;

  public static function setTarget(player:Player):Void {
    _target = player;
  }

  // =======================================
  // ■メンバ変数
  var _type:EnemyType = EnemyType.None;
  var _ai:EnemyAI;
  var _hp:Int;
  var _hpmax:Int;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 16, 16);
    animation.add('${EnemyType.Goast}', [0,  1],  4);
    animation.add('${EnemyType.Bat}',   [4,  5],  4);
    animation.add('${EnemyType.Snake}', [8,  9],  4);
    animation.add('${EnemyType.Skull}', [12, 13], 4);
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float, deg:Float, spd:Float):Void {
    x = X;
    y = Y;
    _type = type;
    setVelocity(deg, spd);

    animation.play('${_type}');
    flipX = false;
    drag.set();
    acceleration.set();

    switch(_type) {
      case EnemyType.None:
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
    _hpmax = _hp;
  }

  override public function kill():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
    _ai = null;
    super.kill();
  }

  /**
   * 敵を倒した
   **/
  public function vanish():Void {
    Global.addScore(200);

    FlxG.camera.shake(0.01, 0.2);
    kill();
  }

  /**
   * HPの残りを取得
   **/
  public function getHpRatio():Float {
    return 100 * _hp / _hpmax;
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
    var spd = 100;
    switch(_type) {
      case EnemyType.Skull, EnemyType.Snake, EnemyType.None:
        spd = 10;
      default:
        spd = 100;
    }
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
      if(_ai != null && isOnScreen()) {
        _ai.attack(this);
      }
    }

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
