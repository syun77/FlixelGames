package jp_2dgames.game.token;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import jp_2dgames.game.util.Field;
import flixel.FlxState;

/**
 * ブロック管理
 **/
class Block extends Token {

  public static var parent:FlxTypedGroup<Block> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>(Field.WIDTH * Field.HEIGHT);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(i:Int, j:Int):Block {
    var block:Block = parent.recycle(Block);
    block.init(i, j);
    return block;
  }

  public function new() {
    super();
    makeGraphic(Field.TILE_WIDTH, Field.TILE_HEIGHT, FlxColor.WHITE);
  }

  public function init(i:Int, j:Int):Void {
    x = Field.toWorldX(i);
    y = Field.toWorldY(j);
    ID = i * j;
  }
}
