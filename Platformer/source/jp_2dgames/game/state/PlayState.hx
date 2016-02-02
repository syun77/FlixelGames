package jp_2dgames.game.state;

import jp_2dgames.game.token.Spike;
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
    var pt = Field.getStartPosition();
    _player = new Player(pt.x, pt.y);
    this.add(_player);

    // 鉄球
    Spike.createParent(this);
    Field.createObjects();

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());
  }

  override public function destroy():Void {

    // マップ破棄
    Field.unload();

    // 鉄球破棄
    Spike.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // 当たり判定
    FlxG.collide(_player, _map);
    FlxG.overlap(_player, Spike.parent, _playerVsSpike);

    _updateDebug();
  }

  /**
   * プレイヤーと鉄球の衝突
   **/
  function _playerVsSpike(player:Player, spike:Spike):Void {
    player.damage(spike);
  }

  function _updateDebug():Void {
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // やり直し
      FlxG.resetState();
    }
  }
}