package jp_2dgames.game.state;

import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Laser;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.lib.Input;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.GameoverUI;
import flixel.util.FlxColor;
import flixel.FlxG;
import jp_2dgames.lib.MyShake;
import flixel.util.FlxTimer;
import jp_2dgames.game.particle.ParticleStartLevel;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.global.Global;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  DeathWait;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  // 敵 or 敵弾の接触ダメージ
  static inline var DAMAGE_VAL:Int = 40;

  var _state:State = State.Init;
  var _bDeath:Bool = false; // 死亡フラグ

  var _cursor:Cursor;
  var _player:Player;
  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // マップ読み込み
    Field.loadLevel(Global.level);

    _cursor = new Cursor();
    // プレイヤー生成
    {
      var pt = Field.getStartPosition();
      _player = new Player(Field.toWorldX(pt.x), Field.toWorldY(pt.y),  _cursor);
      pt.put();
    }
    this.add(_player.light);
    this.add(_player);

    // 敵の生成
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // レーザー
    Laser.createInstance(this);

    // 演出の生成
    Particle.createParent(this);

    this.add(new GameUI());

    // カーソルの生成
    this.add(_cursor);

    // シーケンス管理
    _seq = new SeqMgr(_player);

    // 各種オブジェクト生成
    Field.createObjects();

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Enemy.destroyParent();
    Enemy.setTarget(null);
    Laser.destroyInstance();

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

      case State.DeathWait:
        // 死亡ウェイト

      case State.Gameover:
        /*
        if(Input.press.B) {
          // やり直し
          FlxG.switchState(new PlayInitState());
        }
        */
      case State.Stageclear:
        /*
        if(Input.press.B) {
          // 次のレベルに進む
          StageClearUI.nextLevel();
        }
        */
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

    switch(_seq.proc()) {
      case SeqMgr.RET_DEAD:
        _bDeath = true;
      case SeqMgr.RET_SUCCESS:
        // ステージクリア
        this.add(new StageClearUI(true));
        _state = State.Stageclear;
      case SeqMgr.RET_FAILED:
        // ゲームオーバー
        _startGameover();
        return;
    }

    if(_bDeath) {
      // 死亡フラグが立った
      // オブジェクトの動きを止める
      _player.active = false;
      Enemy.parent.active = false;
      _state = State.DeathWait;
      new FlxTimer().start(0.7, function(timer:FlxTimer) {
        // プレイヤー死亡
        _player.vanish();
        Enemy.parent.active = true;
        _startGameover();
      });
    }
  }


  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI(true));
    if(_player.alive == false) {
      MyShake.high();
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
    }

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
