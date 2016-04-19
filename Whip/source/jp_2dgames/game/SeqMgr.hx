package jp_2dgames.game;

import jp_2dgames.game.token.Door;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Spike;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
import flixel.FlxG;

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

  var _player:Player;
  var _walls:FlxTilemap;
  var _door:Door;

  var _state:State;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, walls:FlxTilemap, door:Door) {
    _player = player;
    _walls = walls;
    _door = door;
    _state  = State.Init;
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
    FlxG.overlap(_player, Spike.parent, _PlayerVsSpike, Token.checkHitCircle);
    FlxG.overlap(_player, _door.spr, _PlayerVsDoor);
  }

  // プレイヤー vs 鉄球
  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    _state = State.Dead;
  }

  // プレイヤー vs ドア
  function _PlayerVsDoor(player:Player, door:Door):Void {
    _state = State.StageClear;
  }

}
