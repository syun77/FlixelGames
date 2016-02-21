package jp_2dgames.game.state;

import jp_2dgames.game.gui.GameoverUI;
import flixel.util.FlxTimer;
import jp_2dgames.game.gui.GameUI;
import flixel.ui.FlxButton;
import jp_2dgames.game.token.Wall;
import jp_2dgames.lib.RectLine;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxRandom;
import nape.phys.Body;
import jp_2dgames.game.token.Hole;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbType;
import flixel.util.FlxColor;
import jp_2dgames.game.token.Ball;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeState;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.Input;
import flixel.FlxG;

private enum State {
  Init;       // ステージ開始
  Main;       // メイン
  Moving;     // ボールが移動中
  Lost;       // ボールを失う演出
  Gameover;   // ゲームオーバー
  Stageclear; // ステージクリア
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxNapeState {

  var _state:State = State.Init;

  var _player:Ball;
  var _line:RectLine;
  var _xprev:Float = 0.0;
  var _yprev:Float = 0.0;
  var _ui:GameUI;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // レベル読み込み
    Field.load(1);

    // 背景画像
    var bg = new FlxSprite(0, 0, AssetPaths.IMAGE_BACK);
    this.add(bg);

    // 穴生成
    Hole.createParent(this);
    // 壁生成
    Wall.createParent(this);
    // ボール生成
    Ball.createParent(this);
    // 補助線生成
    _line = new RectLine(8, FlxColor.WHITE);
    _line.kill();
    this.add(_line);

    // UI
    _ui = new GameUI();
    this.add(_ui);

    // 壁生成
    createWalls(0, 0, FlxG.width, FlxG.height);

    // ボールを配置
    _player = Field.createObjects();

    // 衝突判定のコールバックを登録
    addListener();
  }

  function addListener():Void {
    var listener = new InteractionListener(
      CbEvent.BEGIN, // 開始時
      InteractionType.COLLISION, // 衝突時
      Ball.CB_BALL, // 1つめ(int1)
      Hole.CB_HOLE, // 2つめ(int2)
      function(cb:InteractionCallback) {
        var ball:Ball= cast(cb.int1, Body).userData.data;
        ball.vanish();
      }
    );
    FlxNapeState.space.listeners.add(listener);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    Field.unload();
    Ball.destroyParent();
    Wall.destroyParent();
    Hole.destroyParent();
  }

  function _showMessage(msg:String=null):Void {
    if(msg == null) {
      msg = "Please drag and release";
    }
    _ui.showMessage(msg);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        _state = State.Main;
        _showMessage();

      case State.Main:
        _updateMain();
      case State.Moving:
        if(Ball.isSleepingAll()) {
          // 移動完了
          if(_player.exists == false) {
            // 死んでいたらボールを失う演出
            _showMessage("You lost a ball");
            _state = State.Lost;
            new FlxTimer(1, function(timer:FlxTimer) {
              // ライフを減らす
              Global.subLife(1);
              if(Global.getLife() <= 0) {
                // ゲームオーバー
                this.add(new GameoverUI());
                _state = State.Gameover;
              }
              else {
                // 復活
                _player.setPosition(_xprev, _yprev);
                _player.revive();
                _player.setVelocy(0, 0);
                _showMessage();
                _state = State.Main;
              }
            });
          }
          else {
            _showMessage();
            _state = State.Main;
          }
        }
      case State.Lost:

      case State.Gameover:
        if(Input.press.B) {
          // やり直し
          FlxG.resetState();
        }
      case State.Stageclear:
    }
    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    if(FlxG.mouse.pressed) {
      _line.revive();
      var x1 = _player.xcenter;
      var y1 = _player.ycenter;
      var x2 = FlxG.mouse.x;
      var y2 = FlxG.mouse.y;
      _line.drawLine(x1, y1, x2, y2);
    }
    else {
      _line.kill();
    }
    if(FlxG.mouse.justReleased) {
      // ショット実行
      var dx = FlxG.mouse.x - _player.xcenter;
      var dy = FlxG.mouse.y - _player.ycenter;
      var deg = MyMath.atan2Ex(-dy, dx);
      _player.setVelocy(deg, 1000);
      // 移動前の座標を覚えておく
      _xprev = _player.x + 8;
      _yprev = _player.y + 8;
      _state = State.Moving;
      _ui.hideMessage();
    }
  }

  function _createBall():Void {

    _player = Ball.add(0, 32, 32);

    for(i in 1...9) {
      var px = FlxRandom.floatRanged(32, FlxG.width-32);
      var py = FlxRandom.floatRanged(32, FlxG.height-32);
      Ball.add(i, px, py);
    }
  }

  function _updateDebug():Void {

    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // リスタート
      FlxG.resetState();
    }
  }
}
