package jp_2dgames.game;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Bullet;
import flixel.FlxG;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Laser;
import jp_2dgames.game.token.Player;

/**
 * 状態
 **/
private enum State {
  Init;      // 初期化
  Main;      // メイン
  LaserWait; // レーザー発射演出中
  Success;   // レベルクリア
  Failed;   // ゲームオーバー
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_SUCCESS:Int = 1;
  public static var RET_FAILED:Int  = 2;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡

  var _player:Player;
  var _state:State;
  var _bDead:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    _player = player;
    _state  = State.Init;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;

    switch(_state) {
      case State.Init:
        _state = State.Main;
      case State.Main:
        _updateMain();
      case State.LaserWait:
        _updateLaserWait();
      case State.Success:
        ret = RET_SUCCESS;
      case State.Failed:
        ret = RET_FAILED;
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

    FlxG.overlap(_player, Enemy.parent, function(player:Player, enemy:Enemy) {
      // 敵に接触したので死亡
      _bDead = true;
      Snd.stopMusic();
    });
    FlxG.overlap(_player, Bullet.parent, function(player:Player, bullet:Bullet) {
      // 敵弾に接触したので死亡
      _bDead = true;
      Snd.stopMusic();
    }, Token.checkHitCircle);

    if(Laser.isExists()) {
      _state = State.LaserWait;
    }
  }

  /**
   * 更新・レーザー発射演出
   **/
  function _updateLaserWait():Void {

    if(Enemy.countHit() > 0) {
      // 命中演出中
      return;
    }
    // 命中した敵を消滅
    Enemy.requestVanish();

    if(Enemy.countExists() > 0) {
      // 敵が残っているので失敗
      _state = State.Failed;
    }
    else {
      // 敵をすべて倒したので成功
      _state = State.Success;
    }
  }
}
