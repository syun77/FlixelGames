package jp_2dgames.game.token;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 砲台
 **/
class Infantry extends Token {

  public static var parent:FlxTypedGroup<Infantry> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Infantry>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Infantry {
    var infantry = parent.recycle(Infantry);
    infantry.init(X, Y);
    return infantry;
  }

  // -------------------------------------------------------------------
  // ■フィールド


  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_INFANTRY);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
}
