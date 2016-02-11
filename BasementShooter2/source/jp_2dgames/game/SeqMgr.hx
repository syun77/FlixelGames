package jp_2dgames.game;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;
import flixel.FlxObject;
import flixel.util.FlxRandom;
import jp_2dgames.game.token.Boss;
import jp_2dgames.game.token.enemy.EnemyMgr;
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

  static inline var TIMER_BOSS_APPEAR:Int = 60;

  var _map:FlxTilemap;
  var _player:Player;
  var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new(map:FlxTilemap, player:Player) {

    _map = map;
    _player = player;
    _timer = 0;

    // カメラ設定
//    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
//    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());
  }

  /**
   * 更新
   **/
  public function proc():Int {

    // 衝突判定
    _procCollide();

    var boss = EnemyMgr.bosses.getFirstAlive();
    if(boss == null) {
      // ボスの存在チェック
      _timer++;
      if(_timer > TIMER_BOSS_APPEAR) {
        // ボス出現
        var px:Float = 0;
        var py:Float = 0;
        var w = Field.getWidth();
        var h = Field.getHeight();
        px = FlxRandom.floatRanged(px+32, w);
        py = FlxRandom.floatRanged(py+32, h);
        if(px < 32) { px = 32;}
        if(py < 32) { py = 32;}
        if(px > w-96) { px = w-96; }
        if(py > h-96) { py = h-96; }
        var type = Boss.levelToBossType(Global.getLevel());
        EnemyMgr.addBoss(type, px, py);
        _timer = 0;
        Snd.playMusic('${Global.getLevel()%3+1}');
        // レベルアップ
        Global.addLevel();
      }
    }

    if(_player.exists == false) {
      // ゲームオーバー
      return RET_GAMEOVER;
    }

    return RET_NONE;
  }

  public function _procCollide():Void {
    // 衝突判定
    FlxG.collide(_player, _map);
    FlxG.collide(EnemyMgr.instance, _map, _EnemyVsMap);
    if(_player.isJumpDown() == false) {
      // 飛び降り中でなければ床判定を行う
      FlxG.collide(_player, Floor.parent);
    }

    FlxG.overlap(Shot.parent, EnemyMgr.instance, _ShotVsEnemy);
    FlxG.overlap(Horming.parent, EnemyMgr.instance, _HormingVsEnemy);
    FlxG.overlap(_player, EnemyMgr.enemies, _PlayerVsEnemy);
    FlxG.overlap(_player, EnemyMgr.bosses, _PlayerVsEnemy);
    FlxG.overlap(_player, Bullet.parent, _PlayerVsBullet);
  }

  // 壁と敵の衝突
  function _EnemyVsMap(enemy:Enemy, obj:FlxObject):Void {
    switch(enemy.getType()) {
      case EnemyType.Bat, EnemyType.Bat2:
        // 壁に当たったので消える
        enemy.kill();
      default:
    }
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

  // プレイヤーと敵の衝突
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    if(player.isInvinsible() == false) {
      enemy.damage(5, player);
    }
    player.damage(enemy);
  }

  // プレイヤーと敵弾の衝突
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    player.damage(bullet);
    bullet.kill();
  }
}
