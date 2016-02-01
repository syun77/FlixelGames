package jp_2dgames.game.state;

import flixel.FlxG;
import flixel.tile.FlxTile;
import jp_2dgames.game.token.Player;
import flash.display.BitmapData;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxState;

// オートタイル画像
@:bitmap("assets/data/autotiles.png")
class TileGraphic extends BitmapData {}

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player;
  var _map:FlxTilemap;

  override public function create():Void {
    super.create();

    // マップ読み込み
    var tmx = new TmxLoader();
    tmx.load("assets/data/001.tmx");
    var csv = tmx.getLayerCsv(0);
    _map = new FlxTilemap();
    _map.loadMap(csv, TileGraphic, 0, 0, FlxTilemap.AUTO);
    this.add(_map);

    _player = new Player(0, 0);
    this.add(_player);
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    super.update();

    FlxG.collide(_player, _map);

    _updateDebug();
  }

  function _updateDebug():Void {
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
  }
}