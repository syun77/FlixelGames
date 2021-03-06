package jp_2dgames.game.state;

import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.Snd;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import jp_2dgames.game.token.Trigger;
import jp_2dgames.game.token.Block;
import flixel.FlxObject;
import jp_2dgames.game.token.Floor;
import jp_2dgames.game.token.Pit;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.StageClearUI;
import flixel.FlxSprite;
import jp_2dgames.game.token.Door;
import jp_2dgames.game.token.Spike;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.particle.Particle;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.Input;
import jp_2dgames.game.particle.ParticleStartLevel;
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

  public static var player(get, never):Player;

  var _wall:FlxTilemap;
  var _player:Player;
  var _door:Door;

  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // トゲ生成
    Pit.createParent(this);

    // マップ作成
    Field.loadLevel(Global.level);
    _wall = Field.createWallTile();
    this.add(_wall);

    // 床生成
    Floor.createParent(this);

    // 隠しブロック生成
    Block.createParent(this);

    // ドア生成
    {
      var pt = Field.getGoalPosition();
      _door = new Door(pt.x, pt.y);
      this.add(_door);
    }

    // プレイヤー生成
    _player = new Player(160, 120);
    this.add(_player.getLight());
    this.add(_player.getTrail());
    this.add(_player);

    // トゲ生成
    Spike.createParent(this);

    // トリガー生成
    Trigger.createParent(this);

    // エフェクト生成
    Particle.createParent(this);

    // 各種オブジェクト配置
    Field.createObjects();

    // プレイヤーをスタート地点に移動
    {
      var pt = Field.getStartPosition();
      _player.setPosition(pt.x, pt.y);
      pt.put();
    }
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Floor.destroyParent();
    Trigger.destroyParent();
    Block.destroyParent();
    Pit.destroyParent();
    Spike.destroyParent();
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
        FlxG.collide(Spike.parent, _wall, _SpikeVsWall);
        /*
        if(Input.press.B) {
          // やり直し
          FlxG.switchState(new PlayInitState());
        }
        */
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
    Snd.playMusic('${Global.level}');
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    FlxG.collide(_player, _wall);
    if(_player.isJumpDown() == false) {
      FlxG.collide(_player, Floor.parent);
    }
    FlxG.overlap(_player, Spike.parent, _PlayerVsTrap, Token.checkHitCircle);
    FlxG.overlap(_player, Pit.parent, _PlayerVsTrap, Token.checkHitCircle);
    FlxG.overlap(_player, _door.spr, _PlayerVsDoor);
    FlxG.collide(Spike.parent, _wall, _SpikeVsWall);
    FlxG.collide(_player, Block.parent, _PlayerVsBlock);
    FlxG.overlap(_player, Trigger.parent, _PlayerVsTrigger);
  }

  // プレイヤー vs トラップ
  function _PlayerVsTrap(player:Player, trap:Token):Void {
    // プレイヤー死亡
    _player.vanish();
    // ゲームオーバー
    _startGameover();
  }

  // プレイヤー vs ゴール
  function _PlayerVsDoor(player:Player, spr:FlxSprite):Void {
    // ステージクリア
    _player.vanish();
    this.add(new StageClearUI(false));
    _state = State.Stageclear;
    Snd.stopMusic();
    Snd.playSe("goal");
  }

  // トゲ vs カベ
  function _SpikeVsWall(spike:Spike, wall:FlxObject):Void {
    // カベにぶつかったので反転
    spike.reverse();
  }

  // プレイヤー vs 隠しブロック
  function _PlayerVsBlock(player:Player, block:Block):Void {
    // 出現する
    block.appear();
  }

  // プレイヤー vs トリガー
  function _PlayerVsTrigger(player:Player, trigger:Trigger):Void {
    trigger.action();
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
//    this.add(new GameoverUI());
    FlxG.camera.shake(0.05, 0.4);
    FlxG.camera.flash(FlxColor.WHITE, 0.5);
    Global.subLife(1);
    new FlxTimer().start(2, function(timer:FlxTimer) {
      FlxG.switchState(new PlayStartState());
    });

    Snd.stopMusic();
    Snd.playSe("explosion");
  }

  // -----------------------------------------------
  // ■アクセサ
  static function get_player() {
    return cast(FlxG.state, PlayState)._player;
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
