package jp_2dgames.game;

import jp_2dgames.game.token.Horming;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Bullet;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxCamera;
import jp_2dgames.game.token.enemy.Enemy;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.Floor;
import jp_2dgames.game.util.Field;

/**
 * ゲームシーケンス制御
 **/
class SeqMgr {

  public static inline var RET_NONE:Int = 0;
  public static inline var RET_GAMEOVER:Int = 1;

  var _map:FlxTilemap;
  var _player:Player;

  /**
   * コンストラクタ
   **/
  public function new(map:FlxTilemap, player:Player) {

    _map = map;
    _player = player;

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());
  }

  /**
   * 更新
   **/
  public function proc():Int {

    // 衝突判定
    _procCollide();

    if(_player.exists == false) {
      // ゲームオーバー
      return RET_GAMEOVER;
    }

    return RET_NONE;
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
    FlxG.overlap(Horming.parent, Enemy.parent, _HormingVsEnemy);
  }

  // ショットと敵の衝突
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
    enemy.damage(1, shot);
  }
  // ホーミングと敵の衝突
  function _HormingVsEnemy(horming:Horming, enemy:Enemy):Void {
    horming.vanish();
    enemy.damage(1, horming);
  }

  // プレイヤーと敵弾の衝突
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    player.damage(bullet);
    bullet.kill();
  }
}
