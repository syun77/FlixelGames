package jp_2dgames.game.state;

import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.game.token.Goal;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.gui.GameoverUI;
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

private enum State {
  Init; // 初期化
  Main; // メイン
  Gameover; // ゲームオーバー
  Gameclear; // ゲームクリア
}

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player;
  var _map:FlxTilemap;
  var _goal:Goal;
  var _state:State;

  override public function create():Void {
    super.create();

    // マップ読み込み
    Field.loadLevel(1);
    // 壁生成
    _map = Field.createWallTile();
    this.add(_map);

    // ゴール
    {
      var pt = Field.getGoalPosition();
      _goal = new Goal(pt.x, pt.y);
      this.add(_goal);
    }

    // カーソル
    var cursor = new Cursor();

    // プレイヤー配置
    {
      var pt = Field.getStartPosition();
      _player = new Player(pt.x, pt.y, cursor);
      this.add(_player.getLight());
      this.add(_player);
    }

    // ショット
    Shot.createParent(this);

    // 鉄球
    Spike.createParent(this);

    // 敵
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // 敵弾
    Bullet.createParent(this);

    // パーティクル
    Particle.createParent(this);

    this.add(cursor);

    // UI
    var gameUI = new GameUI();
    this.add(gameUI);

    // カメラ設定
    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());

    // オブジェクト生成
    Field.createObjects();

    _state = State.Main;
  }

  override public function destroy():Void {

    // マップ破棄
    Field.unload();

    // 鉄球破棄
    Spike.destroyParent();
    Shot.destroyParent();
    Enemy.setTarget(null);
    Enemy.destroyParent();
    Bullet.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    // 当たり判定
    FlxG.collide(_player, _map);
    FlxG.collide(Shot.parent, _map, _shotVsWall);
    FlxG.collide(Bullet.parent, _map, _bulletVsWall);
    FlxG.overlap(_player, Spike.parent, _playerVsSpike);
    FlxG.overlap(_player, Enemy.parent, _playerVsEnemy);
    FlxG.overlap(_player, Bullet.parent, _playerVsBullet);
    FlxG.overlap(Shot.parent, Spike.parent, _shotVsSpike);
    FlxG.overlap(Shot.parent, Enemy.parent, _shotVsEnemy);

    if(_player.exists == false) {
      // ゲームオーバー
      _state = State.Gameover;
      var ui = new GameoverUI();
      this.add(ui);
      return;
    }

    FlxG.overlap(_player, _goal, _playerVsGoal);

    _updateDebug();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
      case State.Main:
        _updateMain();
      case State.Gameover:
      case State.Gameclear:
    }
  }

  /**
   * ショットと壁の衝突判定
   **/
  function _shotVsWall(shot:Shot, wall:FlxObject):Void {
    // ショットは壁に当たったら消える
    shot.vanish();
  }
  function _bulletVsWall(bullet:Bullet, wall:FlxObject):Void {
    // 敵弾は壁に当たったら消える
    bullet.vanish();
  }

  /**
   * プレイヤーと鉄球の衝突
   **/
  function _playerVsSpike(player:Player, spike:Spike):Void {
    player.damage(spike);
  }

  /**
   * プレイヤーと敵の衝突
   **/
  function _playerVsEnemy(player:Player, enemy:Enemy):Void {
    player.damage(enemy);
  }
  function _playerVsBullet(player:Player, bullet:Bullet):Void {
    bullet.vanish();
    player.damage(bullet);
  }

  /**
   * ショットと鉄球の衝突
   **/
  function _shotVsSpike(shot:Shot, spike:Spike):Void {
    shot.vanish();
    spike.vanish();
  }

  /**
   * ショットと敵の衝突
   **/
  function _shotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
    enemy.damage(1);
  }

  /**
   * ゴールに到着
   **/
  function _playerVsGoal(player:Player, goal:Goal):Void {
    player.vanish();
    // ステージクリア
    _state = State.Gameclear;
    var ui = new StageClearUI();
    this.add(ui);
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