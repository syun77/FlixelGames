package jp_2dgames.game.token;

import flixel.FlxState;
import flixel.group.FlxTypedGroup;
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
  public static function add(X:Float, Y:Float):Void {
    var wall = parent.recycle(Wall);
    wall.init(X, Y);
  }

  // --------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_WALL);
    immovable = true;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
}
