package jp_2dgames.game.state;

import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.particle.Particle;
import flixel.FlxObject;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.token.Spike;
import flixel.FlxCamera;
import flixel.FlxG;
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

    // カーソル
    var cursor = new Cursor();

    // プレイヤー配置
    var pt = Field.getStartPosition();
    _player = new Player(pt.x, pt.y, cursor);
    this.add(_player);

    // ショット
    Shot.createParent(this);

    // 鉄球
    Spike.createParent(this);
    Field.createObjects();

    // パーティクル
    Particle.createParent(this);

    this.add(cursor);

    // UI
    var gameUI = new GameUI();
    this.add(gameUI);

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());
  }

  override public function destroy():Void {

    // マップ破棄
    Field.unload();

    // 鉄球破棄
    Spike.destroyParent();
    Shot.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // 当たり判定
    FlxG.collide(_player, _map);
    FlxG.collide(Shot.parent, _map, _shotVsWall);
    FlxG.overlap(_player, Spike.parent, _playerVsSpike);
    FlxG.overlap(Shot.parent, Spike.parent, _shotVsSpike);

    _updateDebug();
  }

  /**
   * ショットと壁の衝突判定
   **/
  function _shotVsWall(shot:Shot, wall:FlxObject):Void {
    // ショットは壁に当たったら消える
    shot.vanish();
  }

  /**
   * プレイヤーと鉄球の衝突
   **/
  function _playerVsSpike(player:Player, spike:Spike):Void {
    player.damage(spike);
  }

  /**
   * ショットと鉄球の衝突
   **/
  function _shotVsSpike(shot:Shot, spike:Spike):Void {
    shot.vanish();
    spike.vanish();
  }

  function _updateDebug():Void {
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // やり直し
      FlxG.resetState();
    }
    if(FlxG.keys.justPressed.H) {
      // HP全快
      Global.setLife(100);
    }
  }
}