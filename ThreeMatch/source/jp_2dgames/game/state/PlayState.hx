package jp_2dgames.game.state;

import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.Panel;
import jp_2dgames.game.token.Bg;
import jp_2dgames.lib.Input;
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

  var _state:State = State.Init;
  var _seq:SeqMgr;
  var _player:Player;
  var _enemy:Enemy;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 背景
    var bg = new Bg();
    this.add(bg);

    // プレイヤー
    _player = new Player(FlxG.width*0.7, FlxG.height*0.1);
    this.add(_player);

    // 敵
    _enemy = new Enemy(FlxG.width*0.87, FlxG.height*0.1);
    this.add(_enemy);

    // シーケンス管理
    _seq = new SeqMgr(_enemy);

    // フィールド生成
    Field.create();

    // パネル
    Panel.createParent(this);


    // UI
    this.add(new GameUI(_enemy));

    // TODO:
    _enemy.init(0, 100);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.destroy();
    Panel.destroyParent();

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
        if(Input.press.B) {
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
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    _seq.proc();
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
  }
}
