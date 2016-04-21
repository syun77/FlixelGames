package jp_2dgames.game;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Snd;
import flixel.FlxSprite;
import jp_2dgames.game.token.Hook;
import jp_2dgames.game.token.Rope;
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
  var _rope:Rope;

  var _state:State;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, walls:FlxTilemap, door:Door, rope:Rope) {
    _player = player;
    _walls = walls;
    _door = door;
    _rope = rope;
    _state = State.Init;
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
    var rope = _rope.sprEnd;
    if(rope != null) {
      FlxG.overlap(rope, Hook.parent, _RopeVsHook, _checkHitCircle);
    }
  }

  // プレイヤー vs 鉄球
  function _PlayerVsSpike(player:Player, spike:Spike):Void {
    _state = State.Dead;
  }

  // プレイヤー vs ドア
  function _PlayerVsDoor(player:Player, door:FlxSprite):Void {
    _state = State.StageClear;
    Snd.playSe("goal");
  }

  function _checkHitCircle(spr:FlxSprite, token:Token):Bool {
    var dx = token.xcenter - (spr.x + 2);
    var dy = token.ycenter - (spr.y + 2);
    var r1 = 2;
    var r2 = token.radius;

    return (dx*dx + dy*dy) < (r1*r1 + r2*r2);
  }

  // ロープ vs フック
  function _RopeVsHook(rope:FlxSprite, hook:Hook):Void {
    _rope.setEndPosition(rope.x, rope.y);
    Particle.start(PType.Ring2, rope.x+2, rope.y+2, FlxColor.WHITE);
    Snd.playSe("pit");
  }

}
