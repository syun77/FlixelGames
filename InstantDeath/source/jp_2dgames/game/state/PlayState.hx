package jp_2dgames.game.state;

import jp_2dgames.game.token.Spike;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.particle.Particle;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.Input;
import jp_2dgames.game.particle.ParticleStartLevel;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _wall:FlxTilemap;
  var _player:Player;

  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // マップ作成
    Field.loadLevel(Global.level);
    _wall = Field.createWallTile();
    this.add(_wall);

    // プレイヤー生成
    _player = new Player(160, 120);
    this.add(_player.getLight());
    this.add(_player.getTrail());
    this.add(_player);

    // トゲ生成
    Spike.createParent(this);

    // エフェクト生成
    Particle.createParent(this);

    // 各種オブジェクト配置
    Field.createObjects();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Spike.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
        _state = State.Main;

      case State.Main:
        _updateMain();

      case State.Gameover:
        if(Input.press.A) {
          // やり直し
          FlxG.switchState(new PlayInitState());
        }
      case State.Stageclear:
    }
    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
    ParticleStartLevel.start(this);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    FlxG.collide(_player, _wall);
  }

  // -----------------------------------------------
  // ■アクセサ

  /**
   * デバッグ
   **/
  function _updateDebug():Void {

    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // リスタート
//      FlxG.resetState();
      FlxG.switchState(new PlayInitState());
    }
  }

}
