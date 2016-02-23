package jp_2dgames.game.state;

import jp_2dgames.game.particle.Particle;
import flixel.FlxObject;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxState;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.Input;
import flixel.FlxG;

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

  var _state:State = State.Init;

  var _walls:FlxTilemap;
  var _player:Player;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // マップ読み込み
    Field.loadLevel(1);

    // 壁の生成
    _walls = Field.createWallTiles();
    this.add(_walls);

    // プレイヤーの生成
    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);

    // パーティクルの生成
    Particle.createParent(this);

    Shot.createParent(this);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    Shot.destroyParent();
    Particle.destroyParent();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
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

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    // プレイヤー vs 壁
    FlxG.collide(_player, _walls);
    // ショット vs 壁
    FlxG.collide(Shot.parent, _walls, _ShotVsWall);
  }

  // ショット vs 壁
  function _ShotVsWall(shot:Shot, wall:FlxObject):Void {
    shot.vanish();
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
