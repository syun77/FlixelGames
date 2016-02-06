package jp_2dgames.game.state;

import jp_2dgames.game.token.Enemy.EnemyType;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Shot;
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

  var _seqMgr:SeqMgr;

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
    this.add(player);

    // 敵の生成
    Enemy.createParent(this);
    Enemy.setTarget(player);

    // ショット生成
    Shot.createParent(this);

    // 敵弾生成
    Bullet.createParent(this);

    // パーティクル生成
    Particle.createParent(this);

    // オブジェクト配置
    Field.createObjects();

    _seqMgr = new SeqMgr(map, player);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    Enemy.destroyParent();
    Shot.destroyParent();
    Bullet.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _seqMgr.proc();

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