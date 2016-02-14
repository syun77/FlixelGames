package jp_2dgames.game.state;

import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _map:FlxTilemap;
  var _player:Player;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    Field.loadLevel(1);
    _map = Field.createWallTile();
    this.add(_map);
    _player = new Player(64, 64);
    this.add(_player);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    FlxG.collide(_player, _map);

    #if debug
    _updateDebug();
    #end
  }

  function _updateDebug():Void {

    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // リスタート
      FlxG.resetState();
    }
  }
}
