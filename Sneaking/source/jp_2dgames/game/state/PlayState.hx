package jp_2dgames.game.state;

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
  var _objScroll:FlxObject;

  // 前回マップを生成した座標
  var _yprevmap:Float;

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
    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);

    // 敵の生成
    Enemy.createParent(this);
    Enemy.setTarget(_player);

    // ショットの生成
    Shot.createParent(this);

    // パーティクルの生成
    Particle.createParent(this);


    // マップ読み込み
    _createField();

    // スクロールオブジェクト
    _objScroll = new FlxSprite(FlxG.width/2, FlxG.height/2);
    _objScroll.y = -280;
    _objScroll.velocity.y = -100;
//    _objScroll.visible = false;
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
  }

  /**
   * マップ生成
   **/
  function _createField():Void {
    var rnd = FlxRandom.intRanged(1, 3);
    Field.loadLevel(rnd);
    Field.createObjects(FlxG.camera.scroll.y);
    _yprevmap = FlxG.camera.scroll.y;

    trace("create new map:", rnd);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    var yoffset = FlxG.camera.scroll.y;
    if(yoffset < _yprevmap - Field.getHeight()) {
      // 新しいマップ出現
      _createField();
    }

    FlxG.worldBounds.set(0, yoffset, FlxG.width, FlxG.height);
    Field.updateLayer(yoffset);

    // プレイヤー vs 壁
    FlxG.collide(_player, Wall.parent);
    // ショット vs 壁
    FlxG.collide(Shot.parent, Wall.parent, _ShotVsWall);
    // 敵 vs 壁
    FlxG.collide(Enemy.parent, Wall.parent);
    // ショット vs 敵
    FlxG.overlap(Shot.parent, Enemy.parent, _ShotVsEnemy);
  }

  // ショット vs 壁
  function _ShotVsWall(shot:Shot, wall:Wall):Void {
    shot.vanish();
  }

  // ショット vs 敵
  function _ShotVsEnemy(shot:Shot, enemy:Enemy):Void {
    shot.vanish();
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
