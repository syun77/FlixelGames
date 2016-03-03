package jp_2dgames.game.token;
import jp_2dgames.game.token.Enemy.EnemyAttr;
import jp_2dgames.game.token.Enemy.EnemyAttr;
import flixel.util.FlxTimer;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup;

/**
 * 敵の種類
 **/
enum EnemyType {
  Red;
  Green;
  Blue;
}

/**
 * 敵の属性
 **/
enum EnemyAttr {
  Normal;
  Bomb;
}

/**
 * 敵
 **/
class Enemy extends Token {

  static inline var SLOW_DISTANCE:Float = 32.0;

  public static var parent:FlxTypedGroup<Enemy>;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:EnemyType, attr:EnemyAttr, X:Float, Y:Float, speed:Float):Enemy {
    var enemy = parent.recycle(Enemy);
    enemy.init(type, attr, X, Y, speed);
    return enemy;
  }
  public static function randomType():EnemyType {
    var tbl = [
      EnemyType.Red,
      EnemyType.Green,
      EnemyType.Blue
    ];

    FlxG.random.shuffleArray(tbl, 3);
    return tbl[0];
  }

  /**
   * 色情報の取得
   **/
  public static function typeToColor(type:EnemyType):Int {
    switch(type) {
      case EnemyType.Red:   return 0xFFc0392b;
      case EnemyType.Green: return 0xFF27ae60;
      case EnemyType.Blue:  return 0xFF2980b9;
    }
  }

  // ---------------------------------------------------------------------
  // ■フィールド
  var _type:EnemyType;
  public var type(get, never):EnemyType;
  var _speed:Float;
  var _attr:EnemyAttr;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true);
    _registerAnim();
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, attr:EnemyAttr, X:Float, Y:Float, speed:Float):Void {
    _type = type;
    _attr = attr;
    _speed = speed;
    x = X;
    y = Y;

    color = typeToColor(_type);

    animation.play('${attr}');
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, typeToColor(_type));
    kill();

    switch(_attr) {
      case EnemyAttr.Normal:
      case EnemyAttr.Bomb:
        // 爆風出現
        Blast.add(_type, xcenter, ycenter);
    }
  }

  /**
   * 攻撃演出
   **/
  public function attack():Void {
    Particle.start(PType.Ring3, xcenter, ycenter, typeToColor(_type));

    // 点滅
    var cnt = 8;
    new FlxTimer().start(0.03, function(timer:FlxTimer) {
      var c = typeToColor(_type);
      if(timer.loopsLeft%2 == 1) {
        c = FlxColor.add(c, FlxColor.GRAY);
      }
      color = c;
    }, cnt);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _move();
  }

  /**
   * 移動
   **/
  function _move():Void {

    moves = true;
    if(Blast.getCountExistsCache() > 0) {
      // 爆風が存在する場合停止する
      moves = false;
      return;
    }

    // 中心に向かって移動する
    var cx = FlxG.width/2;
    var cy = FlxG.height/2;

    var dx = cx - xcenter;
    var dy = cy - ycenter;

    var deg = MyMath.atan2Ex(-dy, dx);
    var spd = _speed;
    if((dx*dx + dy*dy) < SLOW_DISTANCE*SLOW_DISTANCE) {
      // 拠点に近づくと速度減少
      spd *= 0.5;
    }
    setVelocity(deg, spd);
  }

  function _registerAnim():Void {
    animation.add('${EnemyAttr.Normal}', [0], 1);
    animation.add('${EnemyAttr.Bomb}', [1], 1);
  }

  function get_type() {
    return _type;
  }

  override public function get_radius() {
    return 4;
  }
}
