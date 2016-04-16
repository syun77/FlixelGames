package jp_2dgames.game.token;

import jp_2dgames.game.global.Global;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 落ちているアイテム
 **/
class DropItem extends Token {

  public static var parent:FlxTypedGroup<DropItem> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<DropItem>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(Itemid:Int, X:Float, Y:Float):DropItem {
    var item = parent.recycle(DropItem);
    item.init(Itemid, X, Y);
    return item;
  }

  // ---------------------------------------------------------
  // ■アクセサ
  var _itemid:Int;
  public var itemid(get, never):Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ITEM, true);
    _registerAnim();
  }

  /**
   * 初期化
   **/
  public function init(Itemid:Int, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _itemid = Itemid;

    animation.play('${Itemid}');
  }

  /**
   * アイテム獲得
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    for(i in 0...Global.MAX_ORB) {
      var idx = i + 8;
      animation.add('${i}', [idx], 1);
    }
  }

  // --------------------------------------------------------
  // ■アクセサ
  function get_itemid() {
    return _itemid;
  }
}
