package jp_2dgames.game.state;

import jp_2dgames.game.particle.ParticleMessage;
import jp_2dgames.game.token.Coin;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.RangeOfView;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Infantry;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.Flag;
import flixel.math.FlxPoint;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.lib.Input;
import flixel.FlxG;
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

  var _flag:Flag;
  var _level:LevelMgr;
  var _cursor:Cursor;
  var _infantroy:Infantry;
  var _view:RangeOfView;
  var _player:Player;

  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // マップ読み込み
    Field.loadLevel(1);
    var map = Field.createWallTile();
    this.add(map);

    // 砲台生成
    Infantry.createParent(this);

    // 移動経路の作成
    var path = Field.createPath(map);
    Enemy.setMapPath(path);

    // 拠点生成
    {
      var pt = Field.getFlagPosition();
      pt.x /= 2;
      pt.y /= 2;
      _flag = new Flag(pt.x, pt.y);
      this.add(_flag);
      pt.put();
    }

    // プレイヤー
    _cursor = new Cursor();
    _view = new RangeOfView();
    _player = new Player(0, 0, _cursor, _view);
    this.add(_player);

    // コイン
    Coin.createParent(this);

    // 敵生成
    Enemy.createParent(this);

    // ショット生成
    Shot.createParent(this);

    // パーティクル
    Particle.createParent(this);
    ParticleMessage.createParent(this);

    // カーソル
    this.add(_cursor);

    // 射程範囲
    this.add(_view);

    // GUI
    this.add(new GameUI());

    // 敵生成管理
    _level = new LevelMgr();
    this.add(_level);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    Infantry.destroyParent();
    Coin.destroyParent();
    Enemy.setMapPath(null);
    Enemy.destroyParent();
    Shot.destroyParent();
    Particle.destroyParent();
    ParticleMessage.destroyParent();
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
        if(Input.press.X) {
          // やり直し
          FlxG.resetState();
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

    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy);
    FlxG.overlap(_player, Coin.parent, _PlayerVsCoin);
    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy);
  }

  // ショット vs 敵
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
    enemy.damage(shot.power);
  }

  // プレイヤー vs コイン
  function _PlayerVsCoin(player:Player, coin:Coin):Void {
    // コイン獲得
    Global.addMoney(1);
    coin.vanish();
  }

  // プレイヤー vs 敵
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    // プレイヤーダメージ
    if(player.visible) {
      player.damage();
    }
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
