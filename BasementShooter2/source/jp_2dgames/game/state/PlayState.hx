package jp_2dgames.game.state;

import jp_2dgames.game.token.enemy.EnemyMgr;
import jp_2dgames.game.token.Horming;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.token.enemy.Enemy;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Floor;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.util.Field;
import flixel.FlxG;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxState;

private enum State {
  Main;
  Gameover;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _seqMgr:SeqMgr;
  var _state:State;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 壁を生成
    Field.loadLevel(Global.getLevel());
    var map = Field.createWallTile();
    this.add(map);

    // 床を生成
    Floor.createParent(this);
    this.add(Floor.parent);

    // プレイヤー生成
    var player = new Player(32, 32);
    this.add(player.getTrail());
    this.add(player.getLight());
    this.add(player.getShield());
    this.add(player);
    var pt = Field.getStartPosition();
    player.setPosition(pt.x, pt.y);

    // 敵の生成
    EnemyMgr.create(this);
    Enemy.setTarget(player);

    // ショット生成
    Shot.createParent(this);
    // ホーミング
    Horming.createParent(this);

    // 敵弾生成
    Bullet.createParent(this);

    // パーティクル生成
    Particle.createParent(this);

    // UI生成
    var gui = new GameUI();
    this.add(gui);

    // オブジェクト配置
    Field.createObjects();

    _seqMgr = new SeqMgr(map, player);
    _state  = State.Main;
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    EnemyMgr.destroy();
    Enemy.setTarget(null);
    Shot.destroyParent();
    Horming.destroyParent();
    Bullet.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        switch(_seqMgr.proc()) {
          case SeqMgr.RET_NONE:
          case SeqMgr.RET_GAMEOVER:
            var ui = new GameoverUI();
            this.add(ui);
            _state = State.Gameover;
        }
      case State.Gameover:
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