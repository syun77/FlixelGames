package jp_2dgames.game.token;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

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
    loadGraphic(AssetPaths.IMAGE_MONEY, true);
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
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.YELLOW);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.YELLOW);
    kill();
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
