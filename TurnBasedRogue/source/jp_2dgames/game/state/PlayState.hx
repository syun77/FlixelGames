package jp_2dgames.game.state;

import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.game.save.Save;
import flixel.FlxSprite;
import jp_2dgames.game.actor.Player;
import flixel.FlxG;
import jp_2dgames.lib.Input;
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

  var _player:Player;
  public var player(get, never):Player;
  var _seq:SeqMgr;

  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 背景の作成
    var bg = new FlxSprite();
    this.add(bg);
    Field.loadLevel(1);
    var layer = Field.getLayer();
    Field.createBackground(layer, bg);

    // プレイヤー生成
    _player = new Player();
    this.add(_player.light);
    this.add(_player);

    // TODO:
    _player.init(8, 8, Dir.Down);

    // シーケンス管理
    _seq = new SeqMgr(_player);
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
//          FlxG.switchState(new PlayInitState());
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
    _seq.proc();
  }

  // -----------------------------------------------
  // ■アクセサ
  function get_player() {
    return _player;
  }

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
    if(FlxG.keys.justPressed.S) {
      // セーブ
      Save.save(true, true);
    }
  }

}
