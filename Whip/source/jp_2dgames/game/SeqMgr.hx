package jp_2dgames.game;

import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Spike;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
import flixel.FlxG;

/**
 * 状態
 **/
private enum State {
  Init;      // 初期化
  Main;      // メイン
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

  var _state:State;
  var _bDead:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, walls:FlxTilemap) {
    _player = player;
    _walls = walls;
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
    }

    if(_bDead) {
      // プレイヤー死亡
      return RET_DEAD;
    }

    return ret;
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    FlxG.collide(_player, _walls);
    FlxG.overlap(_player, Spike.parent, _PlayerVsSpike, Token.checkHitCircle);
  }

  // プレイヤー vs 鉄球
  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    _bDead = true;
  }

}
