package jp_2dgames.game.state;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.gui.HintUI;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import jp_2dgames.game.particle.ParticleMessage;
import jp_2dgames.game.token.Coin;
import jp_2dgames.game.token.Player;
import jp_2dgames.game.token.RangeOfView;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Infantry;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.Flag;
import flixel.math.FlxPoint;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.global.Global;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
  Init;
  WaveWait;
  Main;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  // Wave開始待ち
  static inline var TIMER_WAVE_WAIT:Float = 3.0;

  var _flag:Flag;
  var _level:LevelMgr;
  var _cursor:Cursor;
  var _view:RangeOfView;
  var _player:Player;
  var _tWaveWait:Float = TIMER_WAVE_WAIT;
  var _txtTelop:FlxText;
  var _uiHint:HintUI;

  var _state:State = State.Init;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // マウスカーソルを消す
    FlxG.mouse.visible = false;

    // 初期化
    Global.initLevel();

    // マップ読み込み
    Field.loadLevel(1);
    var map = Field.createWallTile();
    this.add(map);

    // 砲台生成
    Infantry.createParent(this);

    // 移動経路の作成
    var path = Field.createPath(map);
    Enemy.setMapPath(path);

    // 拠点生成
    {
      var pt = Field.getFlagPosition();
      pt.x /= 2;
      pt.y /= 2;
      _flag = new Flag(pt.x, pt.y);
      this.add(_flag);
      pt.put();
    }

    // プレイヤー
    _cursor = new Cursor();
    _view = new RangeOfView();
    _player = new Player(0, 0, _cursor, _view);
    this.add(_player);

    // コイン
    Coin.createParent(this);

    // 敵生成
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // ショット生成
    Shot.createParent(this);

    // 敵弾生成
    Bullet.createParent(this);

    // パーティクル
    Particle.createParent(this);
    ParticleMessage.createParent(this);

    // カーソル
    this.add(_cursor);

    // 射程範囲
    this.add(_view);

    // GUI
    this.add(new GameUI());

    // ヒントUI
    _uiHint = new HintUI(_cursor);
    this.add(_uiHint);

    // テロップテキスト
    _txtTelop = new FlxText(0, FlxG.height*0.3, FlxG.width, '', 16);
    _txtTelop.visible = false;
    this.add(_txtTelop);

    // 敵生成管理
    _level = new LevelMgr();
    this.add(_level);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    Infantry.destroyParent();
    Coin.destroyParent();
    Enemy.setMapPath(null);
    Enemy.destroyParent();
    Shot.destroyParent();
    Bullet.destroyParent();
    Particle.destroyParent();
    ParticleMessage.destroyParent();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
        _state = State.WaveWait;

      case State.WaveWait:
        // WAVE開始前
        _updateWaveWait(elapsed);

      case State.Main:
        _updateMain();

      case State.Gameover:
        if(Input.press.B) {
          // やり直し
          FlxG.switchState(new PlayInitState());
        }
      case State.Stageclear:
    }
    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
    Snd.playMusic("1");
  }

  /**
   * 更新・Wave開始前
   **/
  function _updateWaveWait(elapsed:Float):Void {

    FlxG.overlap(_player, Coin.parent, _PlayerVsCoin);

    _tWaveWait -= elapsed;
    if(_tWaveWait < 0) {
      // Wave開始
      _level.start(Global.level);
      _txtTelop.visible = true;
      _txtTelop.text = 'WAVE ${Global.level}';
      _txtTelop.setFormat(null, 16, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE);
      var px = 0;
      _txtTelop.x = -FlxG.width*0.75;
      FlxTween.tween(_txtTelop, {x:px}, 1, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
        var px2 = FlxG.width * 0.75;
        FlxTween.tween(_txtTelop, {x:px2}, 1, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
          _txtTelop.visible = false;
        }});
      }});
      _txtTelop.scrollFactor.set();

      _state = State.Main;
    }
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy);
    FlxG.overlap(_player, Coin.parent, _PlayerVsCoin);
    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy, Token.checkHitCircle);
    FlxG.overlap(_player, Bullet.parent, _PlayerVsBullet, Token.checkHitCircle);

    if(Global.life < 1) {
      // ゲームオーバー
      FlxG.camera.shake(0.05, 0.4);
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
      _player.active = false;
      _state = State.Gameover;
      Snd.stopMusic();
      Snd.playSe("explosion");
      this.add(new GameoverUI());
      return;
    }

    if(_level.left == 0) {
      if(Enemy.parent.countLiving() == 0) {
        // Waveクリア
        _state = State.WaveWait;
        _tWaveWait = TIMER_WAVE_WAIT;
        // Wave数上昇
        Global.addLevel();
      }
    }
  }

  // ショット vs 敵
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
    enemy.damage(shot.power);
  }

  // プレイヤー vs コイン
  function _PlayerVsCoin(player:Player, coin:Coin):Void {

    if(player.visible == false) {
      return;
    }

    // コイン獲得
    Global.addMoney(1);
    coin.vanish();
  }

  // プレイヤー vs 敵
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    // プレイヤーダメージ
    if(player.visible) {
      player.damage();
    }
  }

  // プレイヤー vs 敵弾
  function _PlayerVsBullet(player:Player, bullet:Bullet):Void {
    // プレイヤーダメージ
    if(player.visible) {
      player.damage();
    }
  }

  /**
   * デバッグ
   **/
  function _updateDebug():Void {

    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // リスタート
//      FlxG.resetState();
      FlxG.switchState(new PlayInitState());
    }
  }
}
