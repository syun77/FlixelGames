package jp_2dgames.game.state;

import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Spike;
import jp_2dgames.game.token.Floor;
import jp_2dgames.lib.Input;
import jp_2dgames.game.token.PlayerMgr;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxState;

private enum State {
  Init;       // ステージ開始
  Main;       // メイン
  Gameover;   // ゲームオーバー
  Stageclear; // ステージクリア
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _map:FlxTilemap;
  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 壁
    Field.loadLevel(1);
    _map = Field.createWallTile();
    this.add(_map);
    // 床
    Floor.createParent(this);
    // 鉄球
    Spike.createParent(this);
    // プレイヤー管理
    PlayerMgr.create(this);
    // パーティクル管理
    Particle.createParent(this);

    // 各種オブジェクト生成
    Field.createObjects();
    // プレイヤー生成
    {
      var pt = Field.getStartPosition();
      PlayerMgr.createPlayer(pt.x, pt.y);
      pt.put();
    }
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    Floor.destroyParent();
    Spike.destroyParent();
    PlayerMgr.destroy();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        _state = State.Main;
      case State.Main:
        _updateMain();
      case State.Gameover:
        if(Input.press.B) {
          // やり直し
          FlxG.resetState();
        }
      case State.Stageclear:
    }
    #if debug
    _updateDebug();
    #end
  }

  function _updateMain():Void {
    // プレイヤーの切り替え
    if(Input.press.X) {
      PlayerMgr.toggle();
    }

    FlxG.collide(PlayerMgr.instance, _map);
    {
      var player = PlayerMgr.getActive();
      if(player != null && player.isJumpDown() == false) {
        // 飛び降り中でない
        FlxG.collide(PlayerMgr.instance, Floor.parent);
      }
    }
    FlxG.overlap(PlayerMgr.instance, Spike.parent, _PlayerVsSpike);
    FlxG.collide(PlayerMgr.get(PlayerType.Red), PlayerMgr.get(PlayerType.Blue));

  }

  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    player.damage();
    var ui = new GameoverUI();
    this.add(ui);
    _state = State.Gameover;
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
