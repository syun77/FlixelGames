package jp_2dgames.game;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * ゲームオブジェクトの基底クラス
 **/
class Token extends FlxSprite {

  public var left(get, never):Float;
  private function get_left() {
    return x;
  }
  public var right(get, never):Float;
  private function get_right() {
    return x + width;
  }

  // 中心座標(X)
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x;
  }
  // 中心座標(Y)
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y;
  }
  // 半径
  public var radius(get, never):Float;
  public function get_radius() {
    return 8;
  }

  /**
   * 画面外に出たかどうか
   **/
  public function isOutside():Bool {

    var cy = FlxG.camera.scroll.y;
    cy += FlxG.height;

    return (y > cy);
  }
}
