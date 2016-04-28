package jp_2dgames.game;


/**
 * 状態
 **/
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
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

  var _player:Actor;
  var _enemy:Actor;

  /**
   * コンストラクタ
   **/
  public function new() {
    _state = State.Init;

    _player = ActorMgr.getPlayer();
    _enemy = ActorMgr.getEnemy();
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

    if(Input.press.A) {

      if(_enemy.isDead()) {
        // 次の敵出現
        var e = new Params();
        e.id = 1;
        _enemy.init(e);
        return;
      }

      var v = FlxG.random.int(30, 40);
      if(FlxG.random.bool()) {
        Message.push2(Msg.ATTACK_BEGIN, [_enemy.getName()]);
        _player.damage(v);

        if(_player.isDead()) {
          Message.push2(Msg.DEAD, [_player.getName()]);
        }
      }
      else {
        Message.push2(Msg.ATTACK_BEGIN, [_player.getName()]);
        _enemy.damage(v);
        if(_enemy.isDead()) {
          Message.push2(Msg.DEFEAT_ENEMY, [_enemy.getName()]);
        }
      }
    }

    if(_player.isDead()) {
      // プレイヤー死亡
      _state = State.Dead;
    }
    if(_enemy.isDead()) {
      // 敵死亡
      _enemy.visible = false;
    }
  }

}
