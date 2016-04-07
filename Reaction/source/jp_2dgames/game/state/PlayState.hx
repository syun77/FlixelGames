package jp_2dgames.game.state;

import jp_2dgames.lib.MyShake;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.Bg;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.lib.Input;
import jp_2dgames.game.particle.ParticleStartLevel;
import flixel.util.FlxTimer;
import jp_2dgames.lib.Snd;
import flixel.util.FlxColor;
import flixel.FlxG;
import jp_2dgames.game.gui.GameoverUI;
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

  var _player:Player;
  var _cursor:Cursor;
  var _levelMgr:LevelMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    _cursor = new Cursor();
    _player = new Player(FlxG.width*0.5, FlxG.height*0.5, _cursor);
    this.add(new Bg(_player));

    this.add(_player);
    this.add(_player.hpbar);

    // 敵
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // ショットの生成
    Shot.createParent(this);

    // 敵弾
    Bullet.createParent(this);

    // 演出の生成
    Particle.createParent(this);

    // UIの生成
    this.add(new GameUI());

    this.add(_cursor);

    // レベル管理生成
    _levelMgr = new LevelMgr(_player);
    this.add(_levelMgr);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Enemy.destroyParent();
    Shot.destroyParent();
    Bullet.destroyParent();
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
    ParticleStartLevel.start(this);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy, Token.checkHitCircle);
    FlxG.overlap(_player, Bullet.parent, _PlayerVsBullet, Token.checkHitCircle);
    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy, Token.checkHitCircle);

    if(_bDeath) {
      // 死亡フラグが立った
      // HPバーの更新
      _player.updateHpBar();
      // オブジェクトの動きを止める
      _player.active = false;
      Enemy.parent.active = false;
      Shot.parent.active = false;
      Bullet.parent.active = false;
      _state = State.DeathWait;
      new FlxTimer().start(0.7, function(timer:FlxTimer) {
        // プレイヤー死亡
        _startGameover();
        _player.active = true;
        Enemy.parent.active = true;
        Shot.parent.active = true;
        Bullet.parent.active = true;
      });
    }
  }

  // プレイヤー vs 敵
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    player.damage(DAMAGE_VAL, enemy);
    enemy.damage(1);
    if(Global.life < 1) {
      // 死亡
      _bDeath = true;
    }
  }

  // プレイヤー vs 敵弾
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    player.damage(DAMAGE_VAL, bullet);
    bullet.vanish();
    if(Global.life < 1) {
      // 死亡
      _bDeath = true;
    }
  }

  // ショット vs 敵
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
    enemy.damage(1);
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI(true));
    MyShake.high();
    FlxG.camera.flash(FlxColor.WHITE, 0.5);
    _player.vanish();
    Snd.playSe("explosion");

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
