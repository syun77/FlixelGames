package jp_2dgames.game.token;

/**
 * カーソル
 **/
import flixel.FlxG;
class Cursor extends Token {
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_CURSOR, true);
    animation.add("play", [0, 1], 4);
    animation.play("play");

    // 中心座標をオフセットする
    offset.set(width/2, height/2);
  }

  public override function update():Void {
    super.update();

    var pt = FlxG.mouse.getWorldPosition();
    x = pt.x;
    y = pt.y;
  }
}
