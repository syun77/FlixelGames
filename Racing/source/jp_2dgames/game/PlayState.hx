package jp_2dgames.game;

import flixel.text.FlxText;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
  Init;     // 初期化
  Main;     // メイン
  Gameover; // ゲームオーバー
}

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player = null;
  var _timer:Int = 0;
  var _txt:FlxText;
  var _txtCaption:FlxText;
  var _bgCaption:FlxSprite;
  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new Bg());

    // プレイヤー
    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);

    // 敵
    Enemy.createParent(this);

    // ハンドルUIの上座標(Y)
    var yhandle:Float = FlxG.height-HandleUI.HEIGHT;

    // ハンドルUI背景
    var bgHandle = new FlxSprite(0, yhandle);
    bgHandle.makeGraphic(FlxG.width, Std.int(HandleUI.HEIGHT), FlxColor.BLACK);
    bgHandle.scrollFactor.set(0, 0);
    this.add(bgHandle);

    // ハンドルUI
    var handle = new HandleUI(0, yhandle, _player);
    this.add(handle);

    _txt = new FlxText(0, 0);
    _txt.scrollFactor.set();
    this.add(_txt);

    // キャプション
    var ycaption = FlxG.height/3;
    _bgCaption = new FlxSprite(0, ycaption);
    _bgCaption.makeGraphic(FlxG.width, 24, FlxColor.BLACK);
    _bgCaption.alpha = 0.5;
    _bgCaption.visible = false;
    _bgCaption.scrollFactor.set();
    this.add(_bgCaption);

    _txtCaption = new FlxText(0, ycaption, FlxG.width, "", 20);
    _txtCaption.setBorderStyle(FlxText.BORDER_OUTLINE);
    _txtCaption.alignment = "center";
    _txtCaption.scrollFactor.set();
    this.add(_txtCaption);

    // プレイヤーをカメラが追いかける
    FlxG.camera.follow(_player);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    _player = null;
    Enemy.destroyParent(this);

    super.destroy();
  }

  /**
   * 状態の変更
   **/
  private function _change(s:State):Void {
    _state = s;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        _change(State.Main);
      case State.Main:
        _updateMain();
      case State.Gameover:
    }

    _updateDebug();
  }

  private function _updateMain():Void {
    _txt.text = 'Enemy: ${Enemy.count()}';

    _timer++;
    if(_timer%120 == 0) {
      var px = Wall.randomX();
      var py = FlxG.camera.scroll.y - 32;
      var spd = FlxRandom.floatRanged(5, 20);
      Enemy.add(px, py, spd);
    }

    if(_player.alive == false) {
      // ゲームオーバー
      _bgCaption.visible = true;
      _txtCaption.text = "GAME OVER";
      _change(State.Gameover);
    }
  }

  private function _updateDebug():Void {
#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}