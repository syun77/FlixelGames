package jp_2dgames.game.state;

import flash.display.BitmapData;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxState;

// オートタイル画像
@:bitmap("assets/data/autotiles.png")
class TileGraphic extends BitmapData {}

class PlayState extends FlxState {
  override public function create():Void {
    super.create();

    var tmx = new TmxLoader();
    tmx.load("assets/data/001.tmx");
    var csv = tmx.getLayerCsv("object");
    var map = new FlxTilemap();
    map.loadMap(csv, TileGraphic, 0, 0, FlxTilemap.AUTO);
    this.add(map);
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    super.update();
  }
}