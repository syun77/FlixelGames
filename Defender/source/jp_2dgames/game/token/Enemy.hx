package jp_2dgames.game.token;
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
  public static function setMapPath(mapPath:Array<FlxPoint>):Void {
    _mapPath = mapPath;
  }

  // -----------------------------------------------
  // ■フィールド
  var _type:EnemyType;
  var _hp:Int;

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
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    angle = 0;
  }

  /**
   * 敵移動経路の設定
   **/
  public function followPath(path:Array<FlxPoint>, speed:Float):Void {
    if(path == null) {
      throw "Error: No valid path";
    }
    x = path[0].x;
    y = path[0].y;

    this.path = new FlxPath().start(path, speed, 0, true);
    this.path.onComplete = _endOfPath;
  }

  /**
   * パスの終端
   **/
  function _endOfPath(flxpath:FlxPath):Void {
    trace("end of path.");
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