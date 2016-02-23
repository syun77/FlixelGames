package jp_2dgames.game.state;

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

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    Field.loadLevel(1);
    var walls = Field.createWallTiles();
    this.add(walls);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
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
