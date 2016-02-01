package jp_2dgames.game.state;

import jp_2dgames.lib.TmxLoader;
import flixel.FlxState;

/**
 * メインゲーム
 **/
class PlayState extends FlxState {
  override public function create():Void {
    super.create();

    // マップ読み込み
    var tmx = new TmxLoader();
    tmx.load("assets/data/001.tmx");
    var layer = tmx.getLayer(0);
    layer.dump();
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    super.update();
  }
}