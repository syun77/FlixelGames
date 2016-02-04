package jp_2dgames.game.token;
import jp_2dgames.lib.Snd;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import openfl._internal.aglsl.assembler.Part;
import jp_2dgames.lib.MyMath;
import flixel.FlxState;

/**
 * 敵の種類
 **/
enum EnemyType {
  Bat;   // コウモリ
  Goast; // ゴースト
}

/**
 * 敵
 **/
class Enemy extends Token {

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
  var _speed:Float;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 16, 16);
    animation.add('${EnemyType.Goast}', [0, 1], 4);
    animation.add('${EnemyType.Bat}',   [4, 5], 4);

    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float):Void {
    x = X + width/2;
    y = Y + height/2;
    _type = type;
    _timer = 0;

    animation.play('${_type}');

    switch(_type) {
      case EnemyType.Bat:
        _speed = 50;
      case EnemyType.Goast:
        _speed = 10;
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
    Snd.playSe("explosion", true);
    kill();
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
  function _bullet(deg:Float, speed:Float):Void {
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
    super.update();

    if(isOnScreen()) {
      var deg = _getAim();
      setVelocity(deg, 10);
    }

    _timer++;
    switch(_type) {
      case EnemyType.Goast:
        if(_timer%180 == 0) {
          var deg = _getAim();
          for(i in 0...3) {
            _bullet(deg+5-5*i, 30);
          }
        }
      case EnemyType.Bat:
    }

  }

  function _getAim():Float {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    return MyMath.atan2Ex(-dy, dx);
  }
}
