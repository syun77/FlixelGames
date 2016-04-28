package jp_2dgames.game.state;

import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.actor.ActorMgr;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxColor;
import jp_2dgames.lib.MyShake;
import jp_2dgames.game.gui.GameoverUI;
import flixel.util.FlxTimer;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.lib.Input;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.global.Global;
import flixel.FlxG;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  DeadWait;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxUIState {

  var _state:State = State.Init;

  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {

    // レイアウトデータ読み込み
    _xml_id = "battle";

    super.create();

    // 初期化
    Global.initLevel();

    // アクターの生成
    ActorMgr.createInstance(this);

    // パーティクル生成
    Particle.createParent(this);

    // メッセージUI生成
    var csv = new CsvLoader(AssetPaths.CSV_MESSAGE);
    Message.createInstance(csv, this);

    // バトルUI生成
    BattleUI.createInstance(this, _ui);

    // プレイヤーの生成
    {
      var p = new Params();
      p.id = 0;
      ActorMgr.add(p);
    }

    // 敵の生成
    {
      var e = new Params();
      e.id = 1;
      ActorMgr.add(e);
    }

    // シーケンス管理生成
    _seq = new SeqMgr();

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    ActorMgr.destroyInstance();
    Particle.destroyParent();
    Message.destroyInstance(this);
    BattleUI.destroyInstance();
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

      case State.DeadWait:
        // 死亡演出終了待ち

      case State.Gameover:
        if(Input.press.B) {
          // やり直し
          FlxG.switchState(new PlayInitState());
        }
      case State.Stageclear:
        if(Input.press.B) {
          // 次のレベルに進む
          StageClearUI.nextLevel();
        }
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

    switch(_seq.proc()) {
      case SeqMgr.RET_DEAD:
        // ゲームオーバー
        _startGameover();
        return;
      case SeqMgr.RET_STAGECLEAR:
        // ステージクリア
        this.add(new StageClearUI(false));
        _state = State.Stageclear;
        Snd.stopMusic();
    }
  }


  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    new FlxTimer().start(0.5, function(timer:FlxTimer) {
      Snd.playSe("explosion");
      _state = State.Gameover;
      this.add(new GameoverUI(false));
      MyShake.high();
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
    });
    _state = State.DeadWait;
    Snd.stopMusic();
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
