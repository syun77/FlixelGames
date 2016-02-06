package jp_2dgames.game.state;

import jp_2dgames.game.token.Floor;
import flixel.FlxCamera;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.util.Field;
import flixel.FlxG;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
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

    Field.loadLevel(Global.getLevel());
    _map = Field.createWallTile();
    this.add(_map);

    Floor.createParent(this);
    this.add(Floor.parent);

    _player = new Player(32, 32);
    this.add(_player.getTrail());
    this.add(_player.getLight());
    this.add(_player);

    // オブジェクト配置
    Field.createObjects();

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());

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
    if(_player.isJumpDown() == false) {
      // 飛び降り中でなければ床判定を行う
      FlxG.collide(_player, Floor.parent);
    }

  #if neko
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