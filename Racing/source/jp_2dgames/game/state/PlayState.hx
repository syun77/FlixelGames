package jp_2dgames.game.state;

import jp_2dgames.game.gui.CaptionUI;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.gui.HandleUI;
import jp_2dgames.game.token.Item;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.particle.ParticleScore;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import jp_2dgames.game.token.Player;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
  Init;     // 初期化
  Main;     // メイン
  Gameover; // ゲームオーバー
}

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player;
  var _captionUI:CaptionUI;
  var _levelMgr:LevelMgr;
  var _seqMgr:SeqMgr;

  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 制限時間
    LimitMgr.create(this);
    LimitMgr.pause();

    // 背景
    this.add(new Bg());

    // プレイヤー
    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);

    // レベル
    _levelMgr = new LevelMgr(_player.getSpeed);
    this.add(_levelMgr);

    // ゲームシーケンス管理
    _seqMgr = new SeqMgr(_player);

    // アイテム
    Item.createParent(this);

    // 敵
    Enemy.createParent(this);

    // スコア演出
    ParticleScore.createParent(this);

    // パーティクル
    Particle.createParent(this);

    // ハンドルUIの上座標(Y)
    var yhandle:Float = FlxG.height-HandleUI.HEIGHT;

    // ハンドルUI背景
    var bgHandle = new FlxSprite(0, yhandle);
    bgHandle.makeGraphic(FlxG.width, Std.int(HandleUI.HEIGHT), FlxColor.BLACK);
    bgHandle.scrollFactor.set(0, 0);
    this.add(bgHandle);

    // ハンドルUI
    var handle = new HandleUI(0, yhandle, _player);
    this.add(handle);

    // ゲームUI
    var gameUI = new GameUI(_player.getSpeed);
    this.add(gameUI);

    // キャプションUI
    _captionUI = new CaptionUI();
    this.add(_captionUI);

    // プレイヤーをカメラが追いかける
    FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN_TIGHT);

    _captionUI.show("READY", false);
    Snd.playSe("levelup");
    new FlxTimer(2, function(timer:FlxTimer) {
      _start(3);
    });
  }

  private function _start(cnt:Int):Void {

    if(cnt <= 0) {
      // ゲーム開始
      LimitMgr.resume();
      _levelMgr.start();
      _captionUI.hide();
      _player.start();
      _change(State.Main);
      Snd.playMusic("001", false);
      return;
    }

    // カウントダウン
    Snd.playSe("countdown");
    _captionUI.show('${cnt}', false);
    new FlxTimer(1, function(timer:FlxTimer) {
      _start(cnt-1);
    });

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    _player = null;
    Particle.destroyParent(this);
    ParticleScore.destroyParent(this);
    Enemy.destroyParent(this);
    Item.destroyParent(this);
    LimitMgr.terminate(this);

    super.destroy();
  }

  /**
   * 状態の変更
   **/
  private function _change(s:State):Void {
    _state = s;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
      case State.Main:
        _updateMain();
      case State.Gameover:
    }

    _updateDebug();
  }

  /**
   * スコア加算
   **/
  private function _addScore(v:Int):Void {
    Global.addScore(v);
  }

  /**
   * 更新・メイン
   **/
  private function _updateMain():Void {

    switch(_seqMgr.proc()) {
      case SeqMgr.RET_NONE:
        // 何もしない

      case SeqMgr.RET_GAMEOVER:
        // ゲームオーバー
        _change(State.Gameover);
        Snd.stopMusic();
        // 画面を揺らす
        FlxG.camera.flash();
        FlxG.camera.shake(0.02, 0.5, function() {
          _captionUI.show("GAME OVER", true);
          _showButton();
        });

      case SeqMgr.RET_TIMEISUP:
        // 時間切れ
        _change(State.Gameover);
        _player.active = false;
        _captionUI.show("TIME IS UP", true);
        _showButton();
    }
  }


  // タイトルへ戻るボタンを表示
  private function _showButton():Void {
    var px = FlxG.width/2;
    var py = FlxG.height/2;
    var btn = new FlxButton(px, py, "Back to TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x -= btn.width/2;
    btn.y -= btn.height/2;
    this.add(btn);
  }

  /**
   * デバッグ機能の更新
   **/
  private function _updateDebug():Void {
#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
#end
  }
}