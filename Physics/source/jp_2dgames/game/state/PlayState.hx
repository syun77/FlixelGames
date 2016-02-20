package jp_2dgames.game.state;

import jp_2dgames.game.token.Ball;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.text.FlxText;
import flixel.addons.nape.FlxNapeSprite;
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

  var _txt:FlxText;
  var _number:Int = 0;

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

    // ボール生成
    Ball.createParent(this);

    // 外周の壁を作成
    createWalls(0, 0, FlxG.width, FlxG.height);

    _createBall(FlxG.width/2, 0);

    _txt = new FlxText(0, 0);
    this.add(_txt);

    // 重力を設定する
//    FlxNapeState.space.gravity.setxy(0, 400);
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
    if(Input.press.A) {
      var px = FlxG.mouse.x;
      var py = FlxG.mouse.y;
      _createBall(px, py);
    }
  }

  function _createBall(px:Float, py:Float):Void {

    var ball = Ball.add(_number, FlxG.mouse.x, FlxG.mouse.y);
    _number++;

    var speed = 1000;
    var deg = FlxRandom.floatRanged(0, 360);
    ball.setVelocy(deg, speed);
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
