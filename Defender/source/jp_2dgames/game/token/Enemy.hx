package jp_2dgames.game.token;
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

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent() {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Enemy {
    var enemy = parent.recycle(Enemy);
    enemy.init(X, Y);
    return enemy;
  }

  // -----------------------------------------------
  // ■フィールド
  var _type:EnemyType;

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
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _type = EnemyType.Goast;
    animation.play('${_type}');
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    animation.add('${EnemyType.Goast}', [0, 1], 4);
    animation.add('${EnemyType.Bat}', [4, 5], 4);
    animation.add('${EnemyType.Goast}', [8, 9], 4);
  }
}
