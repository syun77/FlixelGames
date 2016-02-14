package jp_2dgames.game.state;

import jp_2dgames.lib.Input;
import jp_2dgames.game.token.PlayerMgr;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _map:FlxTilemap;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    Field.loadLevel(1);
    _map = Field.createWallTile();
    this.add(_map);
    PlayerMgr.create(this);

    PlayerMgr.createPlayer(64, 64);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    PlayerMgr.destroy();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // プレイヤーの切り替え
    if(Input.press.X) {
      PlayerMgr.toggle();
    }

    FlxG.collide(PlayerMgr.instance, _map);
    FlxG.collide(PlayerMgr.get(PlayerType.Red), PlayerMgr.get(PlayerType.Blue));

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
