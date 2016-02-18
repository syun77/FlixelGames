package jp_2dgames.game.state;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
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
class PlayState extends FlxNapeState {

  var _state:State = State.Init;

  var _spr:FlxNapeSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 外周の壁を作成
    createWalls(0, 0, FlxG.width, FlxG.height);

    _spr = new FlxNapeSprite(FlxG.width/2, 0);
    _spr.makeGraphic(32, 16);
    _spr.createRectangularBody();
    this.add(_spr);

    // 重力を設定する
    FlxNapeState.space.gravity.setxy(0, 400);
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
//    #if debug
    #if neko
    _updateDebug();
    #end
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    if(Input.press.A) {
      _spr.body.velocity.y = -100;
    }
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
