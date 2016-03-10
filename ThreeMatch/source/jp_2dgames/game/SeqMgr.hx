package jp_2dgames.game;
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
}

/**
 * ゲームシーケンス管理
 **/
class SeqMgr extends FlxBasic {

  var _enemy:Enemy;
  var _state:State = State.Begin;

  /**
   * コンストラクタ
   **/
  public function new(enemy:Enemy) {
    super();

    _enemy = enemy;
    FlxG.watch.add(this, "_state", "Seq.state");
  }

  /**
   * ゲームシーケンス制御
   **/
  public function proc():Void {
    switch(_state) {
      case State.Begin:
        Field.random();
        Field.toWorld();
        _state = State.Standby;

      case State.Standby:
        if(Input.press.A) {
          var mx = Input.mouse.x;
          var my = Input.mouse.y;
          if(Field.checkErase(mx, my, _enemy)) {
            // 消去できた
            _state = State.Erasing;
          }
        }

      case State.Erasing:
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
          // おしまい
          _state = State.Standby;
        }
    }
  }
}
