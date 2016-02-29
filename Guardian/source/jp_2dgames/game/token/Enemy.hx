package jp_2dgames.game.token;
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
 * 敵
 **/
class Enemy extends Token {

  public static var parent:FlxTypedGroup<Enemy>;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:EnemyType, X:Float, Y:Float, speed:Float):Enemy {
    var enemy = parent.recycle(Enemy);
    enemy.init(type, X, Y, speed);
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
      case EnemyType.Red:   return FlxColor.RED;
      case EnemyType.Green: return FlxColor.GREEN;
      case EnemyType.Blue:  return FlxColor.BLUE;
    }
  }

  // ---------------------------------------------------------------------
  // ■フィールド
  var _type:EnemyType;
  var _speed:Float;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(8, 8, FlxColor.WHITE);
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float, speed:Float):Void {
    _type = type;
    _speed = speed;
    x = X;
    y = Y;

    color = typeToColor(_type);
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
    // 中心に向かって移動する
    var cx = FlxG.width/2;
    var cy = FlxG.height/2;

    var dx = cx - xcenter;
    var dy = cy - ycenter;

    var deg = MyMath.atan2Ex(-dy, dx);
    setVelocity(deg, _speed);
  }

}
