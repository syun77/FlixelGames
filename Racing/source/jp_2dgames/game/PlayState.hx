package jp_2dgames.game;

import jp_2dgames.game.Player;
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

  // スコア加算と見なされる距離
  static inline var SCORE_DISTANCE:Int = 100;

  var _player:Player = null;
  var _timer:Int = 0;
  var _txt:FlxText;
  var _txtScore:FlxText;
  var _txtCaption:FlxText;
  var _bgCaption:FlxSprite;
  var _state:State = State.Init;
  var _score:Int = 0;
  var _yprev:Float = 0;
  var _yincrease:Float = 0;

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
    _yprev = _player.y;

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

    // スコアテキスト
    _txtScore = new FlxText(0, 48);
    _txtScore.setBorderStyle(FlxText.BORDER_OUTLINE);
    _addScore(0);
    _txtScore.scrollFactor.set();
    this.add(_txtScore);

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

  /**
   * スコア加算
   **/
  private function _addScore(v:Int):Void {
    _score += v;
    _txtScore.text = 'Score: ${_score}';
  }

  private function _updateMain():Void {
    _txt.text = 'Enemy: ${Enemy.count()}';

    // 敵の出現
    _timer++;
    if(_timer%120 == 0) {
      var px = Wall.randomX();
      var py = FlxG.camera.scroll.y - 32;
      var spd = FlxRandom.floatRanged(5, 20);
      Enemy.add(px, py, spd);
    }

    // 移動距離計算 (上に進むのでマイナスする)
    _yincrease += -(_player.y - _yprev);
    if(_yincrease > SCORE_DISTANCE) {
      var d = Math.floor(_yincrease / SCORE_DISTANCE);
      _addScore(d * 10);
      _yincrease -= d * SCORE_DISTANCE;
    }
    _yprev = _player.y;

    // 衝突判定
    // プレイヤー vs 敵
    Enemy.forEachAlive(function(e:Enemy) {
      var dx = e.xcenter - _player.xcenter;
      var dy = e.ycenter - _player.ycenter;
      if((dx*dx + dy*dy) < (Player.SIZE*Player.SIZE + Enemy.SIZE*Enemy.SIZE)) {
        _player.kill();
      }
    });

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
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
#end
  }
}