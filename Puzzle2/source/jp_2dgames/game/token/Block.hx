package jp_2dgames.game.token;
import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
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

  public function useKey():Void {
    // カギを使った
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.BROWN);

    // カギを減らす
    Global.subKey();

    // 少し揺らす
    FlxG.camera.shake(0.01, 0.2);

    Snd.playSe("damage");
    // 消滅
    kill();
  }
}
