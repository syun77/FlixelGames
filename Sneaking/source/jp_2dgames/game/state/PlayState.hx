package jp_2dgames.game.state;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.token.ScrollObj;
import flixel.util.FlxRandom;
import flixel.FlxSprite;
import flixel.FlxCamera;
import jp_2dgames.game.token.Wall;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.particle.Particle;
import flixel.FlxObject;
import jp_2dgames.game.token.Shot;
import jp_2dgames.game.token.Player;
import flixel.tile.FlxTilemap;
import flixel.FlxState;
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
class PlayState extends FlxState {

  var _state:State = State.Init;

  // プレイヤー
  var _player:Player;

  // スクロールオブジェクト
  var _objScroll:ScrollObj;

  // レベル管理
  var _levelMgr:LevelMgr;


  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 壁の生成
    Wall.creaetParent(this);

    // プレイヤーの生成
    _player = new Player(FlxG.width/2, FlxG.height - 64);
    this.add(_player.light);
    this.add(_player);

    // 敵の生成
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // ショットの生成
    Shot.createParent(this);

    // パーティクルの生成
    Particle.createParent(this);

    // スクロールオブジェクト
    _objScroll = new ScrollObj(FlxG.width/2, FlxG.height/2);
    this.add(_objScroll);

    // レベル管理
    FlxG.camera.scroll.y = FlxG.height;
    _levelMgr = new LevelMgr(_objScroll);
    this.add(_objScroll);

    FlxG.camera.follow(_objScroll, FlxCamera.STYLE_PLATFORMER);

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    Shot.destroyParent();
    Enemy.destroyParent();
    Enemy.setTarget(null);
    Particle.destroyParent();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
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
    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
    _startTelop();
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    // レベル更新
    _levelMgr.proc();

    // プレイヤー vs 壁
    FlxG.collide(_player, Wall.parent);
    // 敵 vs 壁
    FlxG.collide(Enemy.parent, Wall.parent);
    // ショット vs 壁
    FlxG.collide(Shot.parent, Wall.parent, _ShotVsWall);
    // 敵 vs 壁
    FlxG.collide(Enemy.parent, Wall.parent);
    // ショット vs 敵
    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy);

    if(_player.exists == false) {
      // ゲームオーバー
      this.add(new GameoverUI());
      _levelMgr.stop();
      _state = State.Gameover;
    }
  }

  // ショット vs 壁
  function _ShotVsWall(shot:Shot, wall:Wall):Void {
    shot.vanish();
  }

  // ショット vs 敵
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
  }

  /**
   * ステージ開始演出
   **/
  function _startTelop():Void {
    var txt = new FlxText(0, FlxG.height*0.4, FlxG.width, 'START');
    if(Global.getLevel() == Global.MAX_LEVEL-1) {
      txt.text = "FINAL LEVEL";
    }
    txt.setFormat(null, 32, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
    var px = txt.x;
    txt.x = -FlxG.width*0.75;
    FlxTween.tween(txt, {x:px}, 1, {ease:FlxEase.expoOut, complete:function(tween:FlxTween) {
      var px2 = FlxG.width * 0.75;
      FlxTween.tween(txt, {x:px2}, 1, {ease:FlxEase.expoIn, complete:function(tween:FlxTween) {
        txt.visible = false;
      }});
    }});
    txt.scrollFactor.set();
    this.add(txt);
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
