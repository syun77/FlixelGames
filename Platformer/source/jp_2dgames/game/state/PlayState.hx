package jp_2dgames.game.state;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxState;

/**
 * メインゲーム
 **/
class PlayState extends FlxState {
  override public function create():Void {
    super.create();

    this.add(new FlxSprite(0, 0).makeGraphic(16, 16, FlxColor.RED));

    // マップ読み込み
    var tmx = new TmxLoader();
    tmx.load("assets/data/001.tmx");
    var csv = tmx.getLayerCsv(0);
    var map = new FlxTilemap();
    map.loadMap(csv, GraphicAuto, 0, 0, FlxTilemap.AUTO);
    this.add(map);
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    super.update();
  }
}