package jp_2dgames.game.token;
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
    parent = new TokenMgr(32, Enemy);
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

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true);
    animation.add('${EnemyType.Bat}', [0], 1);
    animation.add('${EnemyType.Goast}', [1], 1);

    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float):Void {
    x = X + width/2;
    y = Y + height/2;
    _type = type;

    animation.play('${_type}');
  }

  /**
   * 更新
   **/
  public override function update():Void {
    super.update();

    // TODO:
    var deg = _getAim();
    setVelocity(deg, 10);
  }

  function _getAim():Float {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    return MyMath.atan2Ex(-dy, dx);
  }
}
