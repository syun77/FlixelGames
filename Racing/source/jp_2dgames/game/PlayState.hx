package jp_2dgames.game;

import jp_2dgames.game.Particle.PType;
import flixel.util.FlxTimer;
import flixel.util.FlxPoint;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
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
  var _txtScore:FlxText;
  var _txtSpeed:FlxText;

  var _txtCaption:FlxText;
  var _bgCaption:FlxSprite;
  var _txtResult:FlxText;

  var _state:State = State.Init;
  var _score:Int = 0;
  var _yprev:Float = 0;
  var _yincrease:Float = 0;
  var _tFrame:Int = 0;

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

    // アイテム
    Item.createParent(this);

    // 敵
    Enemy.createParent(this);

    // スコア演出
    ParticleScore.createParent(this);

    // パーティクル
    Particle.createParent(this);

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

    // スコアテキスト
    _txtScore = new FlxText(8, 8);
    _txtScore.setBorderStyle(FlxText.BORDER_OUTLINE);
    _addScore(0);
    _txtScore.scrollFactor.set();
    this.add(_txtScore);

    // 速度
    _txtSpeed = new FlxText(8, 32);
    _txtSpeed.setBorderStyle(FlxText.BORDER_OUTLINE);
    _txtSpeed.scrollFactor.set();
    this.add(_txtSpeed);

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

    _txtResult = new FlxText(0, ycaption+32, FlxG.width, "", 12);
    _txtResult.setBorderStyle(FlxText.BORDER_OUTLINE);
    _txtResult.alignment = "center";
    _txtResult.scrollFactor.set();
    this.add(_txtResult);

    // プレイヤーをカメラが追いかける
    FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN_TIGHT );

    _showCaption("READY?");
    new FlxTimer(3, function(timer:FlxTimer) {
      _hideCaption();
      _player.start();
      _change(State.Main);
    });
  }

  private function _showCaption(msg:String, score:Int=-1):Void {
    _txtCaption.visible = true;
    _bgCaption.visible = true;

    _txtCaption.text = msg;
    if(score >= 0) {
      _txtResult.visible = true;
      _txtResult.text = 'SCORE: ${score}';
    }
  }
  private function _hideCaption():Void {
    _txtCaption.visible = false;
    _bgCaption.visible = false;
    _txtResult.visible = false;
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    _player = null;
    Particle.destroyParent(this);
    ParticleScore.destroyParent(this);
    Enemy.destroyParent(this);
    Item.destroyParent(this);

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

    _tFrame++;

    // 速度更新
    _txtSpeed.text = '${Std.int(_player.getSpeed()/2)}km/h';

    // 敵の出現
    _timer++;
    if(_timer%120 == 0) {
      var px = Wall.randomX();
      var py = FlxG.camera.scroll.y - 32;
      var base = _player.getSpeed();
      var ratio = 0.9 - 0.1 * (Math.sqrt(_tFrame * 0.0001));
      ratio -= FlxRandom.floatRanged(0, 0.2);
      if(ratio < 0.3) {
        ratio = 0.3;
      }
      var spd = base * ratio;
      Enemy.add(px, py, spd);
    }

    // アイテムの出現
    if(_timer%350 == 0) {
      var px = FlxG.width/2 + FlxRandom.intRanged(-32, 32);
      var py = FlxG.camera.scroll.y - 32;
      var spd = _player.getSpeed() * 0.7;
      Item.add(px, py, spd);
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
    // プレイヤー vs アイテム
    Item.forEachAlive(function(item:Item) {
      if(_checkHitCircle(_player, item)) {
        // アイテム獲得
        item.kill();
        _addScore(Item.SCORE);
        // スコア演出
        var px = item.xcenter;
        var py = item.ycenter;
        ParticleScore.start(px, py, Item.SCORE);
        // エフェクト
        Particle.start(PType.Ring, px, py, FlxColor.YELLOW);
        // 速度上昇
        _player.addFrameTimer(60 * 20);
      }
    });
    // プレイヤー vs 敵
    Enemy.forEachAlive(function(e:Enemy) {
      if(_checkHitCircle(_player, e)) {
        _player.vanish();
      }
    });

    if(_player.alive == false) {
      // ゲームオーバー
      _change(State.Gameover);
      // 画面を揺らす
      FlxG.camera.flash();
      FlxG.camera.shake(0.02, 0.5, function() {
        _bgCaption.visible = true;
        _showCaption("GAME OVER", _score);
        _showButton();
      });
    }
  }

  // タイトルへ戻るボタンを表示
  private function _showButton():Void {
    var px = FlxG.width/2;
    var py = FlxG.height/2;
    var btn = new FlxButton(px, py, "Back to TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x -= btn.width/2;
    btn.y -= btn.height/2;
    this.add(btn);
  }

  private static function _checkHitCircle(obj1:Token, obj2:Token):Bool {
    var dx = obj1.xcenter - obj2.xcenter;
    var dy = obj1.ycenter - obj2.ycenter;
    var r1 = obj1.radius;
    var r2 = obj2.radius;

    return (dx*dx + dy*dy) < (r1*r1 + r2*r2);
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