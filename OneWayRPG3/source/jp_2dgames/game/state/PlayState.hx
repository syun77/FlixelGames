package jp_2dgames.game.state;

import jp_2dgames.lib.StatusBar;
import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
import flixel.FlxG;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.ParticleNumber;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.lib.CsvLoader;
import flixel.addons.ui.FlxUIState;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.dat.MyDB;

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

    // 初期化
    Global.initLevel();

    // アイテム抽選情報の生成
    ItemLottery.createInstance(Global.level);

    // 背景生成
    Bg.createInstance(this);

    // アクターの生成
    ActorMgr.createInstance(this);

    // メッセージUI生成
    var csv = new CsvLoader(AssetPaths.CSV_MESSAGE);
    Message.createInstance(csv, this);

    // HPバー
    {
      var hpbarPlayer = new StatusBar(0, 0, 100, 6, true);
      var hpbarEnemy = new StatusBar(0, 0, 100, 6, true);
      this.add(hpbarPlayer);
      this.add(hpbarEnemy);

      // レイアウトデータ読み込み
      _xml_id = "battle";
      super.create();

      var prm = new BattleUIParam();
      prm.ui = _ui;
      prm.hpbarPlayer = hpbarPlayer;
      prm.hpbarEnemy = hpbarEnemy;

      // バトルUI生成
      BattleUI.createInstance(this, prm);
    }


    // パーティクル生成
    Particle.createParent(this);
    ParticleNumber.createParent(this);

    // プレイヤーの生成
    ActorMgr.add(Global.getPlayerParam());

    // 敵の生成
    {
      var p = new Params();
      p.id = EnemiesKind.Slime;
      ActorMgr.add(p);
    }

    // シーケンス管理生成
    _seq = new SeqMgr();
    this.add(_seq);

    // BGM再生
    Snd.playMusic('${Global.level}');

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    ItemLottery.destroyInstance();
    Bg.destroyInstance();
    ActorMgr.destroyInstance();
    Particle.destroyParent();
    ParticleNumber.destroyParent();
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
        // ゲームオーバー

      case State.Stageclear:
        // 次のレベルに進む
        StageClearUI.nextLevel();
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
        _state = State.Stageclear;
        Snd.stopMusic();
        Snd.playSe("foot2");
    }
  }


  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI(true));
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    BattleUI.getEvent(id, sender, data, params);
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
