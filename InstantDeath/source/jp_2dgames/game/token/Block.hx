package jp_2dgames.game.token;

import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 隠しブロック
 **/
class Block extends Token {

  public static var parent:FlxTypedGroup<Block> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Block {
    var block = parent.recycle(Block);
    block.init(X, Y);
    return block;
  }

  // -----------------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK);
    immovable = true;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    visible = false;
    allowCollisions = FlxObject.DOWN; // 下からのみ
  }

  /**
   * 出現する
   **/
  public function appear():Void {

    if(visible) {
      // すでに出現していれば何もしない
      return;
    }

    allowCollisions = FlxObject.ANY;
    visible = true;
    // 出現演出
    var py = y;
    FlxTween.tween(this, {y:py-4}, 0.05, {onComplete:function(tween) {
      FlxTween.tween(this, {y:py}, 0.05);
    }});
  }
}
