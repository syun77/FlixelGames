package jp_2dgames.game.state;

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
import nape.phys.BodyType;
import flixel.util.FlxColor;
import flixel.addons.nape.FlxNapeSprite;
import jp_2dgames.game.token.Ball;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.text.FlxText;
import flixel.addons.nape.FlxNapeState;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.Input;
import flixel.FlxG;

private enum State {
  Init;       // ステージ開始
  Main;       // メイン
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

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 背景画像
    var bg = new FlxSprite(0, 0, AssetPaths.IMAGE_BACK);
    this.add(bg);

    // 穴生成
    Hole.createParent(this);
    // ボール生成
    Ball.createParent(this);
    // 補助線生成
    _line = new RectLine(8, FlxColor.WHITE);
    _line.kill();
    this.add(_line);

    // 壁生成
    createWalls(0, 0, FlxG.width, FlxG.height);

    // TODO: 穴を配置
    Hole.add(FlxG.width/2, FlxG.height/2);

    // ボールを配置
    _createBall();

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

    Ball.destroyParent();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        _state = State.Main;
      case State.Main:
        _updateMain();
      case State.Gameover:
        if(Input.press.B) {
          // やり直し
          FlxG.resetState();
        }
      case State.Stageclear:
    }
//    #if debug
    #if neko
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
      var dx = FlxG.mouse.x - _player.xcenter;
      var dy = FlxG.mouse.y - _player.ycenter;
      var deg = MyMath.atan2Ex(-dy, dx);
      _player.setVelocy(deg, 1000);
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
