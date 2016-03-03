package jp_2dgames.game.state;

import jp_2dgames.game.gui.GameUI;
import jp_2dgames.lib.MyMath;
import jp_2dgames.game.token.Blast;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Flag;
import jp_2dgames.game.gui.GameoverUI;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.display.FlxStarField;
import flixel.util.FlxTimer;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Player;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.FlxState;

private enum State {
  Init;
  Main;
  GameoverWait;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _state:State = State.Init;

  var _player:Player;
  var _flag:Flag;
  var _level:LevelMgr;
  var _combo:ComboCounter;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 背景生成
    var back = new FlxStarField3D();
    this.add(back);

    // 爆風生成
    Blast.createParent(this);

    // 拠点生成
    _flag = new Flag(FlxG.width/2, FlxG.height/2);
    this.add(_flag);

    // プレイヤーの生成
    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);

    // 敵の生成
    Enemy.createParent(this);

    // パーティクル生成
    Particle.createParent(this);

    // 外枠の作成
    _createFrame();

    // UI表示
    this.add(new GameUI());

    // レベルの生成
    _level = new LevelMgr();
    this.add(_level);

    // コンボ管理
    var func = function(combo:Int) {
    };
    _combo = new ComboCounter(func);
    this.add(_combo);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    Blast.destroyParent();
    Enemy.destroyParent();
    Particle.destroyParent();
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
        _state = State.Main;

      case State.Main:
        _updateMain();

      case State.GameoverWait:
        // ゲームオーバーのヒットストップ

      case State.Gameover:
        if(Input.press.X) {
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
    _player.init();
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    // 爆風生存数をキャッシュする
    Blast.countExistCache();

    FlxG.overlap(Enemy.parent, Enemy.parent, _EnemyVsEnemy);
    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy2);
    FlxG.overlap(_player, Enemy.parent, _PlayerVsEnemy, Token.checkHitCircle);
    FlxG.overlap(_flag, Enemy.parent, _FlagVsEnemy, Token.checkHitCircle);
    FlxG.overlap(Blast.parent, Enemy.parent, _BlastVsEnemy, Token.checkHitCircle);
  }

  // プレイヤー vs 敵
  function _PlayerVsEnemy(player:Player, enemy:Enemy):Void {
    if(player.isSame(enemy.type)) {
      // 倒せる
      enemy.vanish();
      _combo.addCombo();
    }
    else {
      // ゲームオーバー
      _startGameover(enemy);
    }
  }

  // 敵が重ならないようにする
  function _EnemyVsEnemy(e1:Enemy, e2:Enemy):Void {
    if(e1.x == e2.x && e1.y == e2.y) {
      // 同一オブジェクト
      return;
    }

    var left1 = e1.x;
    var right1 = e1.x + e1.width;
    var top1 = e1.y;
    var bottom1 = e1.y + e1.height;
    var left2 = e2.x;
    var right2 = e2.x + e2.width;
    var top2 = e2.y;
    var bottom2 = e2.y + e2.height;
    if(left1 >= right2 || right1 <= left2 || top1 >= bottom2 || bottom1 <= top2) {
      // 多重衝突回避
      return;
    }

    var dx = e2.xcenter - e1.xcenter;
    var dy = e2.ycenter - e1.ycenter;

    // 押し返す
    var dist = Math.sqrt(dx*dx + dy*dy);
    var deg = MyMath.atan2Ex(-dy, dx);
    var len = (e1.radius + e2.radius) - dist;
    e2.x += len * MyMath.cosEx(deg);
    e2.y += len * -MyMath.sinEx(deg);
  }

  // プレイヤー vs 敵 (倒す判定のみ)
  function _PlayerVsEnemy2(player:Player, enemy:Enemy):Void {
    if(player.isSame(enemy.type)) {
      // 倒せる
      enemy.vanish();
      _combo.addCombo();
    }
  }

  // 拠点 vs 敵
  function _FlagVsEnemy(flag:Flag, enemy:Enemy):Void {
    // ゲームオーバー
    _startGameover(enemy);
  }

  // 爆風 vs 敵
  function _BlastVsEnemy(blast:Blast, enemy:Enemy):Void {
    if(blast.type == enemy.type) {
      // 同色であれば誘爆する
      enemy.vanish();
      _combo.addCombo();
    }
  }

  /**
   * 背景生成
   **/
  function _createFrame():Void {
    var alpha = 0.2;
    var margin = Std.int(Player.MARGIN - Player.SIZE/2);
    var wall1 = new FlxSprite().makeGraphic(margin, FlxG.height, FlxColor.WHITE);
    wall1.alpha = alpha;
    this.add(wall1);
    var wall2 = new FlxSprite(margin, 0).makeGraphic(FlxG.width-margin, margin, FlxColor.WHITE);
    wall2.alpha = alpha;
    this.add(wall2);
    var wall3 = new FlxSprite(margin, FlxG.height-margin).makeGraphic(FlxG.width-margin, margin, FlxColor.WHITE);
    wall3.alpha = alpha;
    this.add(wall3);
    var wall4 = new FlxSprite(FlxG.width-margin, margin).makeGraphic(margin, FlxG.height-margin*2, FlxColor.WHITE);
    wall4.alpha = alpha;
    this.add(wall4);
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover(enemy:Enemy):Void {
    // 接触した敵を知らせる
    enemy.attack();
    // ヒットストップ
    Enemy.parent.active = false;
    _player.active = false;
    _state = State.GameoverWait;
    new FlxTimer().start(0.5, function(timer:FlxTimer) {
      _player.vanish();
      _flag.vanish();
      this.add(new GameoverUI(true));
      _state = State.Gameover;
    });
  }

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
