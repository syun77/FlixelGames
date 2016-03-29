package jp_2dgames.game.state;

import flixel.util.FlxTimer;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.AttributeUtil.Attribute;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Player;
import flixel.util.FlxColor;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.StageClearUI;
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
  DeathWait;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _player:Player;

  var _state:State = State.Init;
  var _bDeath:Bool = false; // 死亡フラグ

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 背景の生成
    this.add(new Bg());

    // 敵の生成
    Enemy.createParent(this);

    // 敵弾の生成
    Bullet.createParent(this);

    // プレイヤーの生成
    _player = new Player(FlxG.width*0.05, FlxG.height*0.1);
    this.add(_player);
    Enemy.target = _player;

    // 演出の生成
    Particle.createParent(this);

    // TODO: 敵を生成
    Enemy.add(1, Attribute.Red, FlxG.width*0.7, FlxG.height*0.5, 180, 0);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Enemy.destroyParent();
    Enemy.target = null;
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
//    ParticleStartLevel.start(this);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy, Token.checkHitCircle);
    FlxG.overlap(_player, Bullet.parent, _PlayerVsBullet, Token.checkHitCircle);


    if(_player.exists == false) {
      // プレイヤー死亡
      _startGameover();
      return;
    }
    if(_bDeath) {
      // 死亡フラグが立った
      // オブジェクトの動きを止める
      _player.active = false;
      Enemy.parent.active = false;
      Bullet.parent.active = false;
      _state = State.DeathWait;
      new FlxTimer().start(0.7, function(timer:FlxTimer) {
        // プレイヤー死亡
        _player.vanish();
        _startGameover();
      });
    }
  }

  // プレイヤー vs 敵
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    if(player.attribute == enemy.attribute) {
      // 同一属性なので判定不要
      return;
    }
    Particle.start(PType.Ring2, enemy.xcenter, enemy.ycenter, AttributeUtil.toColor(enemy.attribute));
    _bDeath = true;
  }

  // プレイヤー vs 敵弾
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    if(player.attribute == bullet.attribute) {
      // 同一属性
    }
    else {
      // 違う属性なのでプレイヤー死亡
      Particle.start(PType.Ring2, bullet.xcenter, bullet.ycenter, AttributeUtil.toColor(bullet.attribute));
      _bDeath = true;
    }
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI());
    FlxG.camera.shake(0.05, 0.4);
    FlxG.camera.flash(FlxColor.WHITE, 0.5);
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
