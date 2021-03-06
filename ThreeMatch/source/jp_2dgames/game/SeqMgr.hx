package jp_2dgames.game;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.token.Energy;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.Enemy;
import flixel.FlxG;
import jp_2dgames.game.token.Panel;
import jp_2dgames.lib.Input;
import flixel.FlxBasic;

private enum State {
  Begin;   // 開始
  Standby; // 入力待ち
  Erasing; // 消去中
  Falling; // 落下中
  Appear;  // パネル出現
  TurnEnemy; // 敵の行動ターン
  AttackEnemy; // 敵の攻撃
}

/**
 * ゲームシーケンス管理
 **/
class SeqMgr extends FlxBasic {

  var _player:Player;
  var _enemy:Enemy;
  var _state:State = State.Begin;
  var _bSkipTurn:Bool;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, enemy:Enemy) {
    super();

    _player = player;
    _enemy = enemy;
    FlxG.watch.add(this, "_state", "Seq.state");
    _bSkipTurn = false;
  }

  /**
   * ドクロを消す
   **/
  public function killSkull(cnt:Int):Void {
    if(_state != State.Standby) {
      return;
    }

    if(cnt == 0) {
      return;
    }


    if(Field.eraseSkull(cnt)) {
      // 消去できた
      _state = State.Erasing;
      // ターン経過しない
      _bSkipTurn = true;
    }

    Gauge.subPower(100);
  }

  /**
   * ターン遅延発動
   **/
  public function execShoes(cnt:Int):Void {
    if(_state != State.Standby) {
      return;
    }
    if(cnt <= 0) {
      return;
    }

    _enemy.addTurn(cnt);

    Gauge.subSpeed(100);

    Particle.start(PType.Ball2, _enemy.xcenter, _enemy.ycenter, FlxColor.PURPLE);

    Snd.playSe("badstatus");
  }

  /**
   * ゲームシーケンス制御
   **/
  public function proc():Void {
    switch(_state) {
      case State.Begin:
        _state = State.Appear;

      case State.Standby:
        if(Input.press.A) {
          var mx = Input.mouse.x;
          var my = Input.mouse.y;
          if(Field.checkErase(mx, my, _enemy, _player)) {
            // 消去できた
            _player.attack();
            _state = State.Erasing;
          }
        }

      case State.Erasing:

        if(Energy.parent.countLiving() > 0) {
          // エネルギー弾移動中
          return;
        }

        if(Field.checkFall()) {
          _state = State.Falling;
        }
        else {
          // 完了
          _state = State.Appear;
        }

      case State.Falling:
        if(Panel.isMoving() == false) {
          // 移動完了
          _state = State.Appear;
        }

      case State.Appear:
        if(Field.checkAppear()) {
          // 出現
          _state = State.Falling;
        }
        else {
          // 敵の行動開始
          _state = State.TurnEnemy;
        }

      case State.TurnEnemy:

        if(_bSkipTurn) {
          // ターン経過しない
          _bSkipTurn = false;
          // おしまい
          _state = State.Standby;
          return;
        }

        if(_enemy.nextTurn(_player)) {
          // 敵の攻撃開始
          _state = State.AttackEnemy;
        }
        else {
          // おしまい
          _state = State.Standby;
        }

      case State.AttackEnemy:
        if(_enemy.isAttack == false) {
          // 攻撃終了
          // TODO: プレイヤー死亡判定
          _state = State.Standby;
        }
    }
  }
}
