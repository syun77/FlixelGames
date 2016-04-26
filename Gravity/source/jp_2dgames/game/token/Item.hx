package jp_2dgames.game.token;
import jp_2dgames.lib.MyColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import jp_2dgames.lib.Snd;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;

/**
 * アイテム
 **/
class Item  extends Token {

  public static var parent:FlxTypedGroup<Item> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Item>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Item {
    var item = parent.recycle(Item);
    item.init(X, Y);
    return item;
  }

  // -----------------------------------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ITEM, true);
    animation.add("play", [0, 1], 8);
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
   * 消滅
   **/
  public function vanish():Void {
    var c = MyColor.GRAY;
    Particle.start(PType.Ball2, xcenter, ycenter, c);
    Particle.start(PType.Ring2, xcenter, ycenter, c);
    Snd.playSe("item", true);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }
}
