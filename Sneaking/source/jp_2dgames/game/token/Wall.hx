package jp_2dgames.game.token;

import jp_2dgames.game.token.Wall.WallType;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Snd;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 壁の種類
 **/
enum WallType {
  NoDestroy;  // 破壊できない
  CanDestroy; // 破壊可能
}

/**
 * 壁
 **/
class Wall extends Token {

  public static var parent:FlxTypedGroup<Wall> = null;
  public static function creaetParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Wall>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:WallType, X:Float, Y:Float):Void {
    var wall = parent.recycle(Wall);
    wall.init(type, X, Y);
  }
  public static function forEachAlive(func:Wall->Void):Void {
    parent.forEachAlive(func);
  }

  // --------------------------------------------
  // ■フィールド
  var _type:WallType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_WALL, true);
    animation.add('${WallType.NoDestroy}', [0], 1);
    animation.add('${WallType.CanDestroy}', [1], 1);
    immovable = true;
  }

  /**
   * 初期化
   **/
  public function init(type:WallType, X:Float, Y:Float):Void {
    x = X;
    y = Y;

    _type = type;
    animation.play('${_type}');
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.BROWN);
    kill();
  }

  /**
   * ダメージ
   **/
  public function damage():Void {
    if(_type == WallType.CanDestroy) {
      // 破壊可能
      Snd.playSe("damage");
      vanish();
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(isOutside()) {
      // 画面外に出たので消す
      kill();
    }
  }
}
