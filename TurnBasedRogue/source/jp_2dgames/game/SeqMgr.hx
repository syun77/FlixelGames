package jp_2dgames.game;
import flixel.system.debug.console.Console;
import jp_2dgames.game.token.Laser;
import jp_2dgames.lib.Input;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.game.item.ItemType;
import jp_2dgames.lib.MyColor;
import jp_2dgames.game.particle.ParticleNumber;
import flixel.math.FlxPoint;
import jp_2dgames.game.state.PlayState;
import flixel.util.FlxColor;
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

  MissileInput;   // ミサイル発射場所選択
  SwapInput;      // 位置替えの場所選択
  Warp3Input;     // 3マスワープの場所指定

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

  /**
   * ターン数回復
   **/
  public static function recoverTurn(v:Int):Void {
    if(v <= 0) {
      // 回復しない
      return;
    }
    var player = cast(FlxG.state, PlayState).player;
    ParticleNumber.start(player.xcenter, player.ycenter, v, FlxColor.LIME);
    Global.addTurn(v);
  }
  /**
   * ターン数減少
   **/
  public static function damageTurn(v:Int):Void {
    var player = cast(FlxG.state, PlayState).player;
    ParticleNumber.start(player.xcenter, player.ycenter, v, MyColor.SALMON);
    Global.addTurn(v);
  }
  /**
   * アイテムを使用する
   **/
  public static function useItem(type:Int):Bool {
    var seq = cast(FlxG.state, PlayState).seq;
    return seq._useItem(type);
  }


  // -----------------------------------------------------------
  // ■フィールド
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


    if(_player.exists == false) {
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
      case State.MissileInput:   // ミサイル発射場所選択
        _procMissileInput();
      case State.SwapInput:      // 位置替えの場所選択
        _procSwapInput();
      case State.Warp3Input:     // 3マスワープの場所指定
        _procWarp3Input();
      case State.PlayerAct:      // プレイヤーの行動
        if(_player.isTurnEnd()) {
          _change(State.PlayerActEnd);
        }
      case State.PlayerActEnd:   // プレイヤー行動終了
        if(_player.stompChip == StompChip.Stair) {
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
   * ミサイル発射場所選択
   **/
  function _procMissileInput():Void {
    if(Input.press.A) {
      // 敵チェック
      var xc = Cursor.xchip;
      var yc = Cursor.ychip;
      var e = Enemy.getFromPosition(xc, yc);
      // 敵がいる場所を選んだ
      if(e != null) {
        // 倒す
        e.damage(9999);
        // カーソルを消す
        Cursor.setVisibleOneRect(false);
        _change(State.KeyInput);
      }
    }
  }

  /**
   * 位置替え場所選択
   **/
  function _procSwapInput():Void {
    if(Input.press.A) {
      // 敵チェック
      var xc = Cursor.xchip;
      var yc = Cursor.ychip;

      if(Field.isCollide(xc, yc)) {
        // 壁の中
        return;
      }

      var e = Enemy.getFromPosition(xc, yc);
      // 敵がいる場所を選んだ
      if(e != null) {
        // 位置を交換
        var xe = e.xchip;
        var ye = e.ychip;
        e.warp(_player.xchip, _player.ychip);
        _player.warp(xe, ye);
        // カーソルを消す
        Cursor.setVisibleOneRect(false);
        _change(State.KeyInput);
      }
    }
  }

  /**
   * 3マスワープの場所指定
   **/
  function _procWarp3Input():Void {
    if(Input.press.A) {
      // 範囲チェック
      var xc = Std.int(Input.mouse.x / Field.GRID_SIZE);
      var yc = Std.int(Input.mouse.y / Field.GRID_SIZE);
      var dx = xc - _player.xchip;
      var dy = yc - _player.ychip;
      if(Math.abs(dx) > 3 || Math.abs(dy) > 3) {
        // 範囲外
        return;
      }

      if(Field.isCollide(xc, yc)) {
        // 壁の中
        return;
      }

      // 敵チェック
      var e = Enemy.getFromPosition(xc, yc);
      // 敵がいないのでワープできる
      if(e == null) {
        _player.warp(xc, yc);
        // カーソルを消す
        Cursor.setVisibleRange3(false);
        _change(State.KeyInput);
      }
    }
  }

  /**
   * ターン終了処理
   **/
  function _procTurnEnd():Void {

    // 敵ターン終了
    Enemy.forEachAlive(function(e:Enemy) e.turnEnd());

    // プレイヤーターン終了
    _player.turnEnd();

    switch(_player.stompChip) {
      case StompChip.None:
        // 何もなし
      case StompChip.Stair:
        // 階段・次のフロアに進む
        _nextFloor();
        _change(State.NextFloorWait);
        return;
    }

    // ターン経過
    Global.subTurn(1);

    if(Global.turn <= 0) {
      // ターンがなくなったらダメージ
      _player.damage(1);
    }

    /*
    if(_player.exists == false) {
      // プレイヤーが死亡していたらスタート地点に復活
      _player.revive();
      _player.visible = true;
      var pt = Field.getStartPosition();
      var px = Std.int(pt.x);
      var py = Std.int(pt.y);
      _player.warp(px, py);
      // スタート地点に敵がいたら消す
      var e = Enemy.getFromPosition(px, py);
      if(e != null) {
        e.damage(9999);
      }
    }
    */

    _change(State.KeyInput);
  }

  /**
   * 次のフロアに進む
   **/
  function _nextFloor():Void {

    // ターン数回復
    recoverTurn(Consts.RECOVER_NEXT_FLOOR);

    FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() {
      // フェードが完了したら次のフロアへ進む
      Global.addLevel();
      FlxG.switchState(new PlayState());
    });
  }

  /**
   * アイテムを使う
   **/
  function _useItem(type:Int):Bool {
    if(_state != State.KeyInput) {
      // キー入力待ちでないと使えない
      return false;
    }

    // 使えた
    switch(type) {
      case ItemType.PARALYZE:
        Enemy.forEachAlive(function(e:Enemy) {
          // 敵をすべて麻痺させる
          e.changeBadStatus(BadStatus.Paralysis);
        });
      case ItemType.SLOW:
        Enemy.forEachAlive(function(e:Enemy) {
          // 敵をすべてスロウにする
          e.changeBadStatus(BadStatus.Slow);
        });
      case ItemType.TELEPORT:
        // ランダムワープ
        var pt = Field.teleport(_player.xchip, _player.ychip);
        _player.warp(Std.int(pt.x), Std.int(pt.y));
        pt.put();
      case ItemType.MISSILE:
        // ミサイル
        if(Enemy.parent.countLiving() > 0) {
          Cursor.setVisibleOneRect(true);
          _change(State.MissileInput);
        }
        else {
          // 敵がいないので使えない
          return false;
        }
      case ItemType.SWAP:
        // 位置交換
        if(Enemy.parent.countLiving() > 0) {
          Cursor.setVisibleOneRect(true);
          _change(State.SwapInput);
        }
        else {
          // 敵がいないので使えない
          return false;
        }
      case ItemType.WARP3:
        // 3マスワープ
        Cursor.setVisibleRange3(true);
        Cursor.setBasePosition(_player.x, _player.y);
        _change(State.Warp3Input);
      case ItemType.LASER:
        // レーザー
        if(Enemy.parent.countLiving() > 0) {
          var xc = _player.xchip;
          var yc = _player.ychip;
          Enemy.forEachAlive(function(e:Enemy) {
            if(e.xchip == xc || e.ychip == yc) {
              // いずれかの軸が合っていれば倒せる
              e.damage(9999);
            }
          });
          Laser.start(xc, yc);
        }
        else {
          // 敵がいないので使えない
          return false;
        }
      case ItemType.HEAL:
        // ヒール
        _player.recover(Consts.RECOVER_HEAL);
    }
    return true;
  }
}
