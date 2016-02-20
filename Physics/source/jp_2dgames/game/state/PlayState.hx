package jp_2dgames.game.state;

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

  var _spr:FlxNapeSprite;
  var _txt:FlxText;

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

    // 外周の壁を作成
    createWalls(0, 0, FlxG.width, FlxG.height);

    _spr = _createBlock(FlxG.width/2, 0);

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
      _createBlock(px, py);
    }

    if(_spr.body.isSleeping) {
      _txt.text = "sleeping";
    }
    else {
      _txt.text = 'wake up: ${_spr.body.velocity.x},${_spr.body.velocity.y}';
    }
    if(_spr.body.velocity.length < 5) {
      _spr.body.velocity.setxy(0, 0);
    }
  }

  function _createBlock(px:Float, py:Float):FlxNapeSprite {
    var spr = new FlxNapeSprite(px, py);
    spr.makeGraphic(16, 16);
    spr.loadGraphic(AssetPaths.IMAGE_BALL);
    spr.createCircularBody(8);
    var max = 1000;
    var vx = FlxRandom.floatRanged(50, max);
    var vy = FlxRandom.floatRanged(50, max);
    spr.body.velocity.setxy(vx, vy);
    var elasticity = 1; // 弾力性
    var friction = 2; // 摩擦係数
    spr.setBodyMaterial(elasticity, friction, friction, 1, friction);
//    spr.setBodyMaterial(elasticity);
    var drag = 0.99; // 移動摩擦係数
    spr.setDrag(drag, drag);
    this.add(spr);
    return spr;
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
