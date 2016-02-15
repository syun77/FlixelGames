package jp_2dgames.game.state;

import jp_2dgames.game.token.Floor;
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

    // 壁
    Field.loadLevel(1);
    _map = Field.createWallTile();
    this.add(_map);
    // 床
    Floor.createParent(this);
    // プレイヤー管理
    PlayerMgr.create(this);

    // 各種オブジェクト生成
    Field.createObjects();
    // プレイヤー生成
    PlayerMgr.createPlayer(64, 64);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    Floor.destroyParent();
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
    {
      var player = PlayerMgr.getActive();
      if(player.isJumpDown() == false) {
        // 飛び降り中でない
        FlxG.collide(PlayerMgr.instance, Floor.parent);
      }
    }
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
