package jp_2dgames.game.token;

import flixel.FlxG;
import flash.display.BlendMode;
import jp_2dgames.game.AttributeUtil.Attribute;

/**
 * バリア
 **/
class Barrier extends Token {

  // ------------------------------------------
  // ■フィールド
  var _attr:Attribute = Attribute.Red;
  public var attribute(get, never):Attribute;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BARRIER);
    blend = BlendMode.ADD;

    FlxG.watch.add(this, "x", "barrier.x");
    FlxG.watch.add(this, "y", "barrier.y");
  }

  /**
   * 中心座標の設定
   **/
  public function setCenter(px:Float, py:Float):Void {
    x = px - width/2;
    y = py - height/2;
  }

  /**
   * 属性チェンジ
   **/
  public function change(attr:Attribute):Void {
    _attr = attr;
    color = AttributeUtil.toColor(_attr);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var sc = FlxG.random.float(0.8, 1);
//    scale.set(sc);
  }

  // --------------------------------------------
  // ■アクセサ
  function get_attribute() {
    return _attr;
  }

  override public function get_radius():Float {
    return width;
  }
}
