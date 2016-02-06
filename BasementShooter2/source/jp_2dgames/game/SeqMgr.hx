package jp_2dgames.game;

import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Bullet;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxCamera;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.Floor;
import jp_2dgames.game.util.Field;

/**
 * ゲームシーケンス制御
 **/
class SeqMgr {

  var _map:FlxTilemap;
  var _player:Player;

  /**
   * コンストラクタ
   **/
  public function new(map:FlxTilemap, player:Player) {

    _map = map;
    _player = player;

    // TODO: 敵を配置
    Enemy.add(EnemyType.Goast, 320, 240);

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());
  }

  /**
   * 更新
   **/
  public function proc():Void {

    // 衝突判定
    _procCollide();
  }

  public function _procCollide():Void {
    // 衝突判定
    FlxG.collide(_player, _map);
    FlxG.collide(Enemy.parent, _map);
    if(_player.isJumpDown() == false) {
      // 飛び降り中でなければ床判定を行う
      FlxG.collide(_player, Floor.parent);
    }

    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy);
    FlxG.overlap(_player, Bullet.parent, _PlayerVsBullet);
  }

  // ショットと敵の衝突
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.kill();
    enemy.damage(1);
  }

  // プレイヤーと敵弾の衝突
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    player.damage(bullet);
    bullet.kill();
  }
}
