package jp_2dgames.game.state;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.tile.FlxTile;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxState;

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player;
  var _map:FlxTilemap;

  override public function create():Void {
    super.create();

    // マップ読み込み
    Field.loadLevel(1);
    // 壁生成
    _map = Field.createWallTile();
    this.add(_map);

    // プレイヤー配置
    var pt = Field.getPlayerPosition();
    _player = new Player(pt.x, pt.y);
    this.add(_player);

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());
  }

  override public function destroy():Void {

    // マップ破棄
    Field.unload();

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
    if(FlxG.keys.justPressed.R) {
      // やり直し
      FlxG.resetState();
    }
  }
}