package jp_2dgames.game.token;
import jp_2dgames.lib.Snd;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxSpriteUtil;
import flixel.FlxObject;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 敵の種類
 **/
enum EnemyType {
  Goast; // ゴースト
  Bat;   // コウモリ
  Snake; // ヘビ
}

/**
 * 敵
 **/
class Enemy extends Token {

  static var _target:Player = null;
  static var _mapPath:Array<FlxPoint> = null;
  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent() {
    parent = null;
  }
  public static function add(type:EnemyType, speed:Float, hp:Int):Enemy {
    var enemy:Enemy = parent.recycle(Enemy);
    enemy.init(type, hp);
    enemy.followPath(_mapPath, speed);
    return enemy;
  }
  public static function setTarget(target:Player):Void {
    _target = target;
  }
  public static function setMapPath(mapPath:Array<FlxPoint>):Void {
    _mapPath = mapPath;
  }
  public static function forEachAlive(func:Enemy->Void):Void {
    parent.forEachAlive(func);
  }

  /**
   * 一番近くにいる敵を取得する
   **/
  public static function getNearest(obj:FlxSprite):Enemy {
    var distance:Float = 999999;
    var ret:Enemy = null;
    parent.forEachAlive(function(enemy:Enemy) {
      var dist = FlxMath.distanceBetween(obj, enemy);
      if(dist < distance) {
        distance = dist;
        ret = enemy;
      }
    });

    return ret;
  }

  // -----------------------------------------------
  // ■フィールド
  var _type:EnemyType;
  var _hp:Int;
  var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 8, 8);
    _registerAnim();
    flipX = true;
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, hp:Int):Void {
    _type = type;
    _hp   = hp;
    animation.play('${_type}');
    _timer = 0;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.LIME);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.LIME);

    kill();
  }

  public function damage(power:Int):Void {
    _hp -= power;
    if(_hp < 1) {
      // 消滅
      vanish();

      Snd.playSe("damage", true);

      // スコア加算
      Global.addScore(100);

      // コインをばらまく
      var cnt = 1;
      if(Global.level < 2) {
        cnt = 4;
      }
      for(i in 0...cnt) {
        Coin.add(xcenter, ycenter);
      }
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    angle = 0;

    _timer++;
    switch(_type) {
      case EnemyType.Bat:
      case EnemyType.Goast:
        if(_timer%120 == 0) {
          var aim = _getAim();
          for(i in 0...3) {
            var deg = aim - 5 + (5 * i);
            _bullet(deg, 30);
          }
        }
      case EnemyType.Snake:
    }
  }

  /**
   * 敵移動経路の設定
   **/
  public function followPath(path:Array<FlxPoint>, speed:Float):Void {
    if(path == null) {
      throw "Error: No valid path";
    }
    x = path[0].x-4;
    y = path[0].y-4;

    this.path = new FlxPath().start(path, speed, 0, true);
    this.path.onComplete = _endOfPath;
  }

  /**
   * パスの終端
   **/
  function _endOfPath(flxpath:FlxPath):Void {
    // ダメージ演出
    Global.subLife(1);
    FlxG.camera.shake(0.01, 0.2);
    kill();
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    animation.add('${EnemyType.Goast}', [0, 1], 4);
    animation.add('${EnemyType.Bat}', [4, 5], 4);
    animation.add('${EnemyType.Snake}', [8, 9], 4);
  }

  /**
   * 狙い撃ち角度取得
   **/
  function _getAim():Float {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    return MyMath.atan2Ex(-dy, dx);
  }

  /**
   * 弾を撃つ
   **/
  function _bullet(deg:Float, speed:Float):Void {
    Bullet.add(xcenter, ycenter, deg, speed);
  }
}
