package jp_2dgames.game.item;

import jp_2dgames.game.token.Token;
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
  public static function add(xc:Int, yc:Int, itemid:Int):DropItem {
    var item = parent.recycle(DropItem);
    item.init(xc, yc, itemid);
    return item;
  }
  public static function pickup(xc:Int, yc:Int):Void {

    if(Inventory.isFull()) {
      // 拾えない
      return;
    }

    var bFind = false;
    parent.forEachAlive(function(item:DropItem) {
      if(xc != item.xchip || yc != item.ychip) {
        // 拾えない
        return;
      }

      // 拾えた
      bFind = true;
      // インベントリに追加
      Inventory.add(item.ID);
      item.kill();
    });

    if(bFind) {
      var px = Field.toWorldX(xc) + Field.GRID_SIZE/2;
      var py = Field.toWorldY(yc) + Field.GRID_SIZE/2;
      Particle.start(PType.Ring2, px, py, FlxColor.LIME);
    }
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
