package jp_2dgames.game.state;

import flixel.FlxG;
import jp_2dgames.game.token.Player;
import flash.display.BitmapData;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxState;

// オートタイル画像
@:bitmap("assets/data/autotiles.png")
class TileGraphic extends BitmapData {}

class PlayState extends FlxState {

  var _map:FlxTilemap;
  var _player:Player;

  override public function create():Void {
    super.create();

    var tmx = new TmxLoader();
    tmx.load("assets/data/001.tmx");
    var csv = tmx.getLayerCsv("object");
    _map = new FlxTilemap();
    _map.loadMap(csv, TileGraphic, 0, 0, FlxTilemap.AUTO);
    this.add(_map);

    _player = new Player(32, 32);
    this.add(_player.getLight());
    this.add(_player);
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    super.update();

    FlxG.collide(_player, _map);

  #if neko
    _updateDebug();
  #end
  }

  function _updateDebug():Void {
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
  }
}