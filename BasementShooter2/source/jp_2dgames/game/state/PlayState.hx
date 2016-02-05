package jp_2dgames.game.state;

import jp_2dgames.game.global.Global;
import jp_2dgames.game.util.Field;
import flixel.FlxG;
import jp_2dgames.game.token.Player;
import flash.display.BitmapData;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxState;

class PlayState extends FlxState {

  var _map:FlxTilemap;
  var _player:Player;

  override public function create():Void {
    super.create();

    Field.loadLevel(Global.getLevel());
    _map = Field.createWallTile();
    this.add(_map);

    _player = new Player(32, 32);
    this.add(_player.getLight());
    this.add(_player);
  }

  override public function destroy():Void {

    Field.unload();

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