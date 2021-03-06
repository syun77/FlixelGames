package jp_2dgames.game.state;

import jp_2dgames.lib.Input;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.token.Door;
import flixel.FlxSprite;
import jp_2dgames.game.token.Shot;
import flixel.group.FlxGroup;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.Block;
import jp_2dgames.game.util.Field;
import flixel.FlxG;
import flixel.FlxState;

private enum State {
  Main;
  Gameover;
  Gameclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _floors:FlxGroup;
  var _player:Player;
  var _level:LevelMgr;
  var _door:Door;

  var _ui:GameUI;
  var _state:State = State.Main;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // フィールド生成
    Field.create();
    // 床と壁の生成
    _floors = Field.createFloor();
    this.add(_floors);

    // ドアの生成
    _door = new Door(FlxG.width/2, 64);
//    _door.y = FlxG.height - 96;
    this.add(_door);

    // ブロック管理生成
    Block.createParent(this);

    // プレイヤー生成
    _player = new Player(FlxG.width/2, FlxG.height-Field.TILE_HEIGHT*2);
    this.add(_player);

    // ショット
    Shot.createParent(this);

    Particle.createParent(this);

    // UI
    _ui = new GameUI();
    this.add(_ui);

    // レベル管理生成
    _level = new LevelMgr();
    this.add(_level);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    Field.destroy();
    Block.destroyParent();
    Shot.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        FlxG.overlap(Shot.parent, Block.parent, _ShotVsBlock);
        FlxG.overlap(Shot.parent, _floors, _ShotVsFloors);
        FlxG.collide(_floors, Block.parent);
        FlxG.collide(Block.parent, Block.parent, _BlockVsBlock);
        FlxG.collide(_player, _floors);
        if(_player.exists == false) {
          // ゲームオーバー
          _ui.stop(false);
          Snd.stopMusic();
          _level.stop();
          _state = State.Gameover;
          this.add(new GameoverUI());
        }
        else {
          // クリア判定
          FlxG.overlap(_player, _door.spr, _PlayerVsDoor);
        }
      case State.Gameover:
        if(Input.press.B) {
          FlxG.switchState(new PlayInitState());
        }
      case State.Gameclear:
    }

    #if neko
    _updateDebug();
    #end
  }

  function _ShotVsBlock(shot:Shot, block:Block):Void {
    shot.vanish();
    block.vanish();
  }
  function _ShotVsFloors(shot:Shot, floor:FlxSprite):Void {
    shot.vanish();
  }

  function _BlockVsBlock(b1:Block, b2:Block):Void {
    if(b1.y < b2.y) {
      b1.snapGrip();
    }
    else {
      b2.snapGrip();
    }
  }
  function _PlayerVsDoor(player:Player, door:FlxSprite):Void {
    // ゲームクリア
    _player.kill();
    _state = State.Gameclear;
    _level.stop();
    Block.parent.forEachAlive(function(block:Block) {
      block.vanish();
    });
    _ui.stop(true);
    this.add(new StageClearUI());
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
    if(FlxG.mouse.justPressed) {
      _player.x = FlxG.mouse.x;
      _player.y = FlxG.mouse.y;
    }
  }
}