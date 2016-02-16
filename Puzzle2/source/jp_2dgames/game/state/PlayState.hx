package jp_2dgames.game.state;

import jp_2dgames.game.token.Gate;
import jp_2dgames.game.gui.StageClearUI;
import flixel.FlxSprite;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.token.Door;
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
  var _goal:FlxSprite;
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
    // ゲート
    Gate.createParent(this);
    // ゴール
    {
      var pt = Field.getGoalPosition();
      var door = new Door(pt.x, pt.y);
      this.add(door);
      _goal = door.spr;
    }
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
    }

    // カメラ設定
    PlayerMgr.lockCameraActive();
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    Floor.destroyParent();
    Gate.destroyParent();
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
        if(Input.press.B) {
          // 次のステージに進む
          if(Global.addLevel()) {
            // ゲームクリア
            FlxG.switchState(new EndingState());
          }
          else {
            FlxG.switchState(new PlayState());
          }
        }
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

    // プレイヤーと壁
    FlxG.collide(PlayerMgr.instance, _map);
    // プレイヤーと床
    var player = PlayerMgr.getActive();
    if(player != null) {

      // ゴール判定
      FlxG.overlap(player, _goal, _PlayerVsGoal);
      if(_state != State.Main) {
        // ゴールした
        return;
      }

      if(player.isJumpDown() == false) {
        // 飛び降り中でない
        FlxG.collide(PlayerMgr.instance, Floor.parent);
      }
    }
    // プレイヤー同士
    FlxG.collide(PlayerMgr.get(PlayerType.Red), PlayerMgr.get(PlayerType.Blue));
    // プレイヤーとゲート
    FlxG.overlap(PlayerMgr.instance, Gate.parent, _PlayerVsGate);
    // プレイヤーと鉄球
    FlxG.overlap(PlayerMgr.instance, Spike.parent, _PlayerVsSpike);
  }

  function _PlayerVsGate(player:Player, gate:Gate):Void {
    // ゲートの位置に非アクティブなプレイヤーをワープ
    var player2 = PlayerMgr.getNonActive();
    player2.x = gate.x;
    player2.y = gate.y;
    gate.vanish();
  }

  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    player.damage();
    var ui = new GameoverUI();
    this.add(ui);
    _state = State.Gameover;
  }
  function _PlayerVsGoal(player:Player, goal:FlxSprite):Void {
    PlayerMgr.forEachAlive(function(player:Player) {
      player.vanish();
    });
    var ui = new StageClearUI();
    this.add(ui);
    _state = State.Stageclear;
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
