package jp_2dgames.game.token;

/**
 * アイテム
 **/
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.ParticleScore;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
class Item extends Token {

  public static inline var SCORE:Int = 1000;

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

  // スコア
  var _score:Int = 0;

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

    _score = SCORE;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    // スコア加算
    Global.addScore(_score);

    // スコア演出
    var px = xcenter;
    var py = ycenter;
    ParticleScore.start(px, py, Item.SCORE);
    // エフェクト
    Particle.start(PType.Ring, px, py, FlxColor.YELLOW);

    // 消滅
    kill();
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
