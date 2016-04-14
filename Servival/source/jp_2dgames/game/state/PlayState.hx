package jp_2dgames.game.state;

import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.gui.GameUI;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
import jp_2dgames.lib.Snd;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.lib.MyShake;
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
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _state:State = State.Init;

  var _field:FlxTilemap;
  var _player:Player;
  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // フィールド
    Field.loadLevel(Global.level);
    _field = Field.createWallTile();
    _field.visible = false;
    this.add(_field);

    // 背景表示
    {
      var bg = new FlxSprite();
      var layer = Field.getLayer();
      Field.createBackground(layer, bg);
      this.add(bg);
    }

    // プレイヤー生成
    _player = new Player(Global.xstart, Global.ystart);
    this.add(_player.light);
    this.add(_player);

    // 敵の生成
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // ショットの生成
    Shot.createParent(this);

    // 敵弾の生成
    Bullet.createParent(this);

    // パーティクル生成
    Particle.createParent(this);

    // UI
    this.add(new GameUI());

    // シーケンス管理生成
    _seq = new SeqMgr(_player, _field);

    Enemy.add(1, 96, 96, 0, 0);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    Enemy.destroyParent();
    Enemy.setTarget(null);
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
      case SeqMgr.RET_MOVE_LEVEL:
        // 別のレベルへ移動
        FlxG.switchState(new PlayState());
        return;
    }
  }


  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI(true));
    MyShake.high();
    FlxG.camera.flash(FlxColor.WHITE, 0.5);

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
