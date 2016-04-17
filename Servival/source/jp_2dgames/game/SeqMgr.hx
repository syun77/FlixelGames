package jp_2dgames.game;

/**
 * 状態
 **/
import flixel.FlxObject;
import jp_2dgames.game.token.DropItem;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.DirUtil.Dir;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
private enum State {
  Init;      // 初期化
  Main;      // メイン
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static var RET_MOVE_LEVEL:Int = 4; // レベル移動
  public static var RET_GAMECLEAR:Int  = 5; // ゲームクリア

  var _state:State;
  var _bDead:Bool = false;
  var _bMoveLevel:Bool = false;
  var _player:Player;
  var _field:FlxTilemap;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, field:FlxTilemap) {

    _player = player;
    _field = field;

    _state  = State.Init;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;

    switch(_state) {
      case State.Init:
        // 初期化
        _state = State.Main;
      case State.Main:
        // メイン
        _updateMain();
    }

    if(_player.alive == false) {
      // プレイヤー死亡
      return RET_DEAD;
    }
    if(_bMoveLevel) {
      // レベル移動
      return RET_MOVE_LEVEL;
    }
    if(Global.completeOrb()) {
      // ゲームクリア
      return RET_GAMECLEAR;
    }

    return ret;
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    FlxG.collide(_player, _field);
    Enemy.parent.forEachAlive(function(e:Enemy) {
      if(e.fly != EnemyFly.Wall) {
        FlxG.collide(e, _field, _EnemyVsField);
      }
    });
    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy);
    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy);
    FlxG.overlap(_player, Bullet.parent, _PlayerVsBullet);
    FlxG.overlap(_player, DropItem.parent, _PlayerVsDropItem);

    // 別のレベルへ移動するかどうかをチェック
    var dir = _checkMoveLevel();
    if(dir != Dir.None) {
      // レベル移動する
      if(_moveLevel(dir)) {
        // レベル移動できた
        _bMoveLevel = true;
      }
    }
  }

  // 敵 vs カベ
  function _EnemyVsField(enemy:Enemy, wall:FlxObject):Void {
    if(enemy.isReflect()) {
      enemy.velocity.x = enemy.vxprev * -1;
      enemy.velocity.y = enemy.vyprev * -1;
    }
  }

  // ショット vs 敵
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    enemy.damage(shot.dir, 1);
  }

  // プレイヤー vs 敵
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    _player.damage(enemy, 40);
  }

  // プレイヤー vs 敵弾
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    _player.damage(bullet, 30);
    bullet.vanish();
  }

  // プレイヤー vs アイテム
  function _PlayerVsDropItem(player:Player, item:DropItem):Void {
    Global.discoverOrb(item.itemid);
    item.vanish();
  }

  /**
   * 別のレベルへ移動するかどうかチェック
   **/
  function _checkMoveLevel():Dir {
    var x1 = _player.left;
    var y1 = _player.top;
    var x2 = _player.right;
    var y2 = _player.bottom;

    var gs = Field.GRID_SIZE;
    if(x2 < gs) {
      Global.setStartPosition(FlxG.width-gs*1.5, y1);
      return Dir.Left; // 左のマップへ移動
    }
    if(y2 < gs) {
      Global.setStartPosition(x1, FlxG.height-gs*1.5);
      return Dir.Up; // 上のマップへ移動
    }
    if(x1 > FlxG.width-gs) {
      Global.setStartPosition(gs/2, y1);
      return Dir.Right; // 右のマップへ移動
    }
    if(y1 > FlxG.height-gs) {
      Global.setStartPosition(x1, gs/2);
      return Dir.Down; // 下のマップへ移動
    }

    // 移動しない
    return Dir.None;
  }

  /**
   * 別のレベルへ移動する
   **/
  function _moveLevel(dir:Dir):Bool {

    var levelWidth:Int = 4;
    var levelHeight:Int = 4;


    var now:Int = Global.level-1;
    var next:Int = -1;
    switch(dir) {
      case Dir.Left:
        if(now%levelWidth == 0) {
          // 移動不可
          return false;
        }
        next = now - 1;
      case Dir.Up:
        if(now < levelWidth) {
          // 移動不可
          return false;
        }
        next = now - levelWidth;
      case Dir.Right:
        if(now%levelWidth == levelWidth-1) {
          // 移動不可
          return false;
        }
        next = now + 1;
      case Dir.Down:
        if(now/levelWidth >= levelHeight-1) {
          // 移動不可
          return false;
        }
        next = now + levelWidth;
      default:
        // あり得ない
        throw 'Error: Invalid dir = ${dir}';
    }

    // 移動可能
    Global.setLevel(next+1);
    return true;
  }
}
