package jp_2dgames.game.token;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * アイテム
 **/
class Item extends Token {

  public static var parent:FlxTypedGroup<Item> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Item>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Item {
    var item:Item = parent.recycle(Item);
    item.init(X, Y);
    return item;
  }
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_KEY, true);
    animation.add("play", [0, 1], 4);
    animation.play("play");
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }

  /**
   * アイテム獲得
   **/
  public function pickup():Void {
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.YELLOW);

    // カギの数を増やす
    Global.addKey();
    Snd.playSe("item");

    kill();
  }
}
