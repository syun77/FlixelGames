package jp_2dgames.game.token;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 動かないブロック
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
    var block:Block = parent.recycle(Block);
    block.init(X, Y);
    return block;
  }

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_LOCK, true);
    animation.add("play", [0, 1], 4);
    animation.play("play");
    immovable = true;
  }

  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
}
