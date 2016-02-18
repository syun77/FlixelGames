package jp_2dgames.game.state;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import jp_2dgames.game.token.Switch;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.token.Item;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.Block;
import jp_2dgames.game.token.Gate;
import jp_2dgames.game.gui.StageClearUI;
import flixel.FlxSprite;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.token.Door;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Spike;
import jp_2dgames.game.token.Floor;
import jp_2dgames.lib.Input;
import jp_2dgames.game.token.PlayerMgr;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.FlxState;

private enum State {
  Init;       // ステージ開始
  Main;       // メイン
  Gameover;   // ゲームオーバー
  Stageclear; // ステージクリア
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _map:FlxTilemap;
  var _goal:FlxSprite;
  var _ui:GameUI;
  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 壁
    Field.loadLevel(Global.getLevel());
    _map = Field.createWallTile();
    this.add(_map);
    // 床
    Floor.createParent(this);
    // ゲート
    Gate.createParent(this);
    // ゴール
    {
      var pt = Field.getGoalPosition();
      var door = new Door(pt.x, pt.y);
      this.add(door);
      _goal = door.spr;
    }
    // 鉄球
    Spike.createParent(this);
    // ブロック
    Block.createParent(this);
    // スイッチ
    Switch.createParent(this);
    // アイテム
    Item.createParent(this);
    // プレイヤー管理
    PlayerMgr.create(this);
    // パーティクル管理
    Particle.createParent(this);

    // ゲームUI生成
    _ui = new GameUI();
    this.add(_ui);

    // 各種オブジェクト生成
    Field.createObjects();
    // プレイヤー生成
    {
      var pt = Field.getStartPosition();
      PlayerMgr.createPlayer(pt.x, pt.y);
    }

    // カメラ設定
    PlayerMgr.lockCameraActive();
    FlxG.worldBounds.set(0, 0, Field.getWidth(), Field.getHeight());

    if(Global.getLevel()%2 == 1) {
      Snd.playMusic("1");
    }
    else {
      Snd.playMusic("2");
    }

    // ステージ開始演出
    {
      var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, 'LEVEL ${Global.getLevel()}', 16);
      if(Global.getLevel() == Global.MAX_LEVEL-1) {
        txt.text = "FINAL LEVEL";
      }
      txt.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
      var px = txt.x;
      txt.x = -FlxG.width*0.75;
      FlxTween.tween(txt, {x:px}, 1, {ease:FlxEase.expoOut, complete:function(tween:FlxTween) {
        var px2 = FlxG.width * 0.75;
        FlxTween.tween(txt, {x:px2}, 1, {ease:FlxEase.expoIn, complete:function(tween:FlxTween) {
          txt.visible = false;
        }});
      }});
      txt.scrollFactor.set();
      this.add(txt);
    }

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Field.unload();
    Floor.destroyParent();
    Gate.destroyParent();
    Spike.destroyParent();
    Block.destroyParent();
    Switch.destroyParent();
    Item.destroyParent();
    PlayerMgr.destroy();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        _state = State.Main;
      case State.Main:
        _updateMain();
      case State.Gameover:
        if(Input.press.B) {
          // やり直し
          FlxG.resetState();
        }
      case State.Stageclear:
        if(Input.press.B) {
          // 次のステージに進む
          if(Global.addLevel()) {
            // ゲームクリア
            FlxG.switchState(new EndingState());
          }
          else {
            FlxG.switchState(new PlayState());
          }
        }
    }
    #if debug
    _updateDebug();
    #end
  }

  function _updateMain():Void {
    // プレイヤーの切り替え
    if(Input.press.X) {
      PlayerMgr.toggle();
    }

    // プレイヤーと壁
    FlxG.collide(PlayerMgr.instance, _map);
    // プレイヤーとブロック
    FlxG.collide(PlayerMgr.instance, Block.parent, _PlayerVsBlock);
    // プレイヤーと床
    var player = PlayerMgr.getActive();
    if(player != null) {

      // ゴール判定
      FlxG.overlap(player, _goal, _PlayerVsGoal);
      if(_state != State.Main) {
        // ゴールした
        return;
      }

      if(player.isJumpDown() == false) {
        // 飛び降り中でない
        FlxG.collide(PlayerMgr.instance, Floor.parent);
      }
    }
    // プレイヤー同士
    FlxG.collide(PlayerMgr.get(PlayerType.Red), PlayerMgr.get(PlayerType.Blue));
    // プレイヤーとゲート
    FlxG.overlap(PlayerMgr.instance, Gate.parent, _PlayerVsGate);
    // プレイヤーとアイテム
    FlxG.overlap(PlayerMgr.instance, Item.parent, _PlayerVsItem);
    // プレイヤーと鉄球
    FlxG.overlap(PlayerMgr.instance, Spike.parent, _PlayerVsSpike);
    // プレイヤーとスイッチ
    FlxG.overlap(PlayerMgr.instance, Switch.parent, _PlayerVsSwitch);
//    FlxG.overlap(PlayerMgr.getActive(), Switch.parent, _PlayerVsSwitch);
  }

  function _PlayerVsGate(player:Player, gate:Gate):Void {
    // ゲートの位置に非アクティブなプレイヤーをワープ
    var player2 = PlayerMgr.getNonActive();
    player2.warp(gate.x, gate.y);
    gate.vanish();
    Snd.playSe("warp");
  }
  function _PlayerVsItem(player:Player, item:Item):Void {
    // アイテム獲得
    item.pickup();
  }

  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    player.damage();
    Snd.stopMusic();
    var ui = new GameoverUI();
    this.add(ui);
    _state = State.Gameover;
  }
  function _PlayerVsGoal(player:Player, goal:FlxSprite):Void {
    PlayerMgr.forEachAlive(function(player:Player) {
      player.vanish();
    });
    // リトライボタンを消す
    _ui.hideRetry();
    var ui = new StageClearUI();
    this.add(ui);
    _state = State.Stageclear;
    Snd.stopMusic();
    Snd.playSe("goal");
  }
  function _PlayerVsBlock(player:Player, block:Block):Void {
    if(Global.hasKey()) {
      // カギがあれば破壊可能
      block.useKey();
    }
  }
  function _PlayerVsSwitch(player:Player, sw:Switch):Void {
    // スイッチを押した
    sw.hit();
  }

  function _updateDebug():Void {

    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // リスタート
      FlxG.resetState();
    }
  }
}
