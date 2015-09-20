package jp_2dgames.game;

/**
 * アイテム
 **/
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
class Item extends Token {

  // 半径サイズ
  override public function get_radius() {
    return 8;
  }

  static var _parent:FlxTypedGroup<Item> = null;
  public static function createParent(state:FlxState):Void {
    _parent = new FlxTypedGroup<Item>(32);
    for(i in 0..._parent.maxSize) {
      _parent.add(new Item());
    }
    state.add(_parent);
  }
  public static function destroyParent(state:FlxState):Void {
    state.remove(_parent);
    _parent = null;
  }
  public static function forEachAlive(func:Item->Void):Void {
    _parent.forEachAlive(func);
  }
  public static function add(X:Float, Y:Float, Speed:Float):Item {
    var item:Item = _parent.recycle();
    item.init(X, Y, Speed);

    return item;
  }
  public static function count():Int {
    return _parent.countLiving();
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(Reg.PATH_IMAGE_ITEM_SCORE);

    // 非表示にしておく
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, Speed:Float):Void {
    x = X;
    y = Y;
    velocity.y = -Speed;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(isOutside()) {
      // 画面外に出たので消滅
      kill();
    }
  }
}
