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
  public function init(itemid:Int, X:Float, Y:Float):Void {
    x = X;
    y = Y;

    animation.play('${itemid}');
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    for(i in 0...4) {
      var idx = i + 8;
      animation.add('${i}', [idx], 1);
    }
  }
}
