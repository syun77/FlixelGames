package jp_2dgames.game.token;

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
  public static function add(xc:Int, yc:Int, itemid:Int):DropItem {
    var item = parent.recycle(DropItem);
    item.init(xc, yc, itemid);
    return item;
  }

  // ------------------------------------------------------
  // ■フィールド
  var _xchip:Int;
  var _ychip:Int;
  var _itemid:Int;

  public var xchip(get, never):Int;
  public var ychip(get, never):Int;

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
  public function init(xc:Int, yc:Int, itemid:Int):Void {
    ID = itemid;
    animation.play('${itemid}');

    _xchip = xc;
    _ychip = yc;
    x = Field.toWorldX(xc);
    y = Field.toWorldY(yc);
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    for(i in 0...8) {
      animation.add('${i}', [i], 1);
    }
  }

  // ---------------------------------------------------------
  // ■アクセサ
  function get_xchip() {
    return _xchip;
  }
  function get_ychip() {
    return _ychip;
  }
}
