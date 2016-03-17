package jp_2dgames.game;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.actor.Enemy;
import flixel.FlxG;
import jp_2dgames.game.actor.Actor.Action;
import jp_2dgames.game.actor.Player;

/**
 * 状態
 **/
private enum State {
  KeyInput;       // キー入力待ち
  PlayerAct;      // プレイヤーの行動
  PlayerActEnd;   // プレイヤー行動終了
  EnemyRequestAI; // 敵のAI
  Move;           // 移動
  EnemyActBegin;  // 敵の行動開始
  EnemyAct;       // 敵の行動
  EnemyActEnd;    // 敵の行動終了
  TurnEnd;        // ターン終了
  NextFloorWait;  // 次のフロアに進む（完了待ち）
  GameClear;      // ゲームクリア
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  // updateの戻り値
  public static inline var RET_NONE:Int = 0; // 何もなし
  public static inline var RET_GAMEOVER:Int = 1; // ゲームオーバー

  var _player:Player;

  var _state:State = State.KeyInput;
  var _stateprev:State = State.KeyInput;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    _player = player;

    FlxG.watch.add(this, "_state", "SeqMgr.state");
    FlxG.watch.add(this, "_stateprev", "SeqMgr.stateprev");
  }

  /**
   * 更新
   **/
  public function update():Int {

    // シーケンス実行
    var cnt:Int = 0;
    var bLoop = true;
    while(bLoop) {
      bLoop = _proc();
      cnt++;
      if(cnt > 100) {
        break;
      }
    }

    if(Global.turn <= 0) {
      // ゲームオーバー
      return RET_GAMEOVER;
    }
    else {
      // 何もなし
      return RET_NONE;
    }
  }

  /**
   * 状態遷移
   **/
  function _change(s:State):Void {
    _stateprev = _state;
    _state = s;
  }

  /**
   * 更新
   **/
  function _proc():Bool {

    var ret = false;
    _player.proc();
    Enemy.forEachAlive(function(e:Enemy) e.proc());

    switch(_state) {
      case State.KeyInput:       // キー入力待ち
        switch(_player.action) {
          case Action.Standby, Action.None, Action.MoveExec, Action.ActExec:
            // 何もしない
          case Action.Act:
            // プレイヤー行動
            _player.beginAction();
            _change(State.PlayerAct);
            ret = true;
          case Action.Move:
            // プレイヤー移動
            _change(State.PlayerActEnd);
            ret = true;
          case Action.TurnEnd:
            // 足踏み待機
            _change(State.PlayerActEnd);
            // いったん制御を返して連続回復しないようにする
            ret = false;
        }
      case State.PlayerAct:      // プレイヤーの行動
        if(_player.isTurnEnd()) {
          _change(State.PlayerActEnd);
        }
      case State.PlayerActEnd:   // プレイヤー行動終了
        if(false) {
          // 階段を踏んでいれば次のフロアに移動
          _change(State.NextFloorWait);
        }
        else {
          // 敵のAI開始
          _change(State.EnemyRequestAI);
        }

      case State.EnemyRequestAI: // 敵のAI
        // 敵の行動を要求する
        Enemy.forEachAlive(function(e:Enemy) e.requestMove());

        if(_player.isTurnEnd()) {
          // プレイヤーの行動が終わっていれば敵のみ行動開始
          _change(State.EnemyActBegin);
          ret = true;
        }
        else {
          // プレイヤーと敵が一緒に移動する
          _player.beginMove();
          // 敵の移動
          _moveAllEnemies();
          _change(State.Move);
          ret = true;
        }

      case State.Move:           // 移動
        if(_player.isTurnEnd()) {
          // 敵の行動開始
          _change(State.EnemyActBegin);
          ret = true;
        }

      case State.EnemyActBegin:  // 敵の行動開始
        var bStart = false;
        // 敵の行動開始チェック
        Enemy.forEachAlive(function(e:Enemy) {
          if(bStart == false) {
            // 誰も行動していなければ行動する
            if(e.action == Action.Act) {
              e.beginAction();
              bStart = true;
            }
          }
        });

        ret = true;
        _change(State.EnemyAct);

      case State.EnemyAct:       // 敵の行動
        var isNext       = true;  // 次に進むかどうか
        var isActRemain  = false; // 行動していない敵がいる
        var isMoveRemain = false; // 移動していない敵がいる

        // 敵のアクションチェック
        Enemy.forEachAlive(function(e:Enemy) {
          switch(e.action) {
            case Action.ActExec:
              isNext = false; // アクション実行中
            case Action.MoveExec:
              isNext = false; // 移動中
            case Action.Act:
              isActRemain = true; // アクション実行待ち
            case Action.Move:
              isMoveRemain = true; // 移動待ち
            case Action.TurnEnd:
              // ターン終了
            default:
              // 通常ここにはこない
              throw('Error: Invalid action = ${e.action}');
          }
        });

        if(isNext) {
          // 敵が行動完了した
          if(isActRemain) {
            // 次の敵を動かす
            _change(State.EnemyActBegin);
          }
          else if(isMoveRemain) {
            // 移動待ちの敵を動かす
            _moveAllEnemies();
          }
          else {
            // 敵の行動終了
            _change(State.EnemyActEnd);
          }
        }

      case State.EnemyActEnd:    // 敵の行動終了
        _change(State.TurnEnd);

      case State.TurnEnd:        // ターン終了
        _procTurnEnd();
        ret = true;

      case State.NextFloorWait:  // 次のフロアに進む（完了待ち）
        // 何もしない

      case State.GameClear:      // ゲームクリア
    }

    return ret;
  }

  /**
   * 敵をすべて動かす
   **/
  function _moveAllEnemies():Void {
    Enemy.forEachAlive(function(e:Enemy) {
      if(e.action == Action.Move) {
        e.beginMove();
      }
    });
  }

  /**
   * ターン終了処理
   **/
  function _procTurnEnd():Void {

    // 敵ターン終了
    Enemy.forEachAlive(function(e:Enemy) e.turnEnd());

    // プレイヤーターン終了
    _player.turnEnd();

    // ターン経過
    Global.subTurn(1);

    _change(State.KeyInput);
  }
}
