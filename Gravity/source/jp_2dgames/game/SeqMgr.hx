package jp_2dgames.game;

import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Item;
import jp_2dgames.game.token.Spike;
import flixel.FlxSprite;
import jp_2dgames.game.token.Door;
import jp_2dgames.game.token.Floor;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;

/**
 * 状態
 **/
private enum State {
  Init;       // 初期化
  Main;       // メイン
  Dead;       // 死亡
  StageClear; // ステージクリア
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static var RET_STAGECLEAR:Int  = 5; // ステージクリア

  var _state:State;
  var _bDead:Bool = false;
  var _bStageClear:Bool = false;

  var _player:Player;
  var _walls:FlxTilemap;
  var _door:Door;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, walls:FlxTilemap, door:Door) {
    _state = State.Init;

    _player = player;
    _walls = walls;
    _door = door;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;

    switch(_state) {
      case State.Init:
        // 初期化
        _state = State.Main;
      case State.Main:
        // メイン
        _updateMain();
      case State.Dead:
        // プレイヤー死亡
        return RET_DEAD;
      case State.StageClear:
        // ステージクリア
        return RET_STAGECLEAR;
    }

    return RET_NONE;
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    FlxG.collide(_player, _walls);
    FlxG.collide(_player, Floor.parent, _PlayerVsFloor);
    FlxG.overlap(_player, _door.spr, _PlayerVsDoor);
    FlxG.overlap(_player, Spike.parent, _PlayerVsSpike, Token.checkHitCircle);
    FlxG.overlap(_player, Item.parent, _PlayerVsItem);

    if(_bDead) {
      // 死亡
      _state = State.Dead;
    }
    else if(_bStageClear) {
      // ステージクリア
      _state = State.StageClear;
    }
  }

  // プレイヤー vs 一方通行床
  function _PlayerVsFloor(player:Player, floor:Floor):Void {
    // 床消える
    floor.vanish();
    // 自動ジャンプ
    player.jump();
  }

  // プレイヤー vs ゴール
  function _PlayerVsDoor(player:Player, door:FlxSprite):Void {
    if(_door.enabled) {
      // ステージクリア
      _bStageClear = true;
    }
  }

  // プレイヤー vs 鉄球
  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    // 死亡
    _bDead = true;
    _player.damage();
    _player.moves = false;
  }

  // プレイヤー vs コイン
  function _PlayerVsItem(player:Player, item:Item):Void {
    item.vanish();

    if(Item.parent.countLiving() == 0) {
      // ゴールを有効にする
      _door.setEnable();
    }
  }

}
