package jp_2dgames.game.state;

import jp_2dgames.game.token.DropItem;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.actor.Params;
import jp_2dgames.game.particle.ParticleNumber;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.save.Save.LoadType;
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
    Field.loadLevel(Global.level);
    var layer = Field.getLayer();
    Field.createBackground(layer, bg);

    // アイテム生成
    DropItem.createParent(this);

    // プレイヤー生成
    _player = new Player();
    this.add(_player);

    // 敵生成
    Enemy.createParent(this);
    this.add(_player.light);

    // パーティクル
    Particle.createParent(this);
    ParticleNumber.createParent(this);

    // UI
    this.add(new GameUI());

    // TODO:
    _player.init(8, 8, Dir.Down);
    var params = new Params();
    params.id = 1;
    Enemy.add(1, 1, Dir.Down, params);
    DropItem.add(1, 5, 7);

    // シーケンス管理
    _seq = new SeqMgr(_player);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    DropItem.destroyParent();
    Enemy.destroyParent();
    Particle.destroyParent();
    ParticleNumber.destroyParent();

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
    switch(_seq.update()) {
      case SeqMgr.RET_NONE:
        // 何もなし
      case SeqMgr.RET_GAMEOVER:
        // ゲームオーバー
        this.add(new GameoverUI(true));
        _state = State.Gameover;
    }
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
    if(FlxG.keys.justPressed.A) {
      // ロード
      Save.load(LoadType.All, true, true);
    }
  }

}
