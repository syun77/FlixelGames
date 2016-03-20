package jp_2dgames.game.state;

import jp_2dgames.game.particle.ParticleMessage;
import jp_2dgames.game.token.Bg;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.actor.Params;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import jp_2dgames.game.token.Heart;
import jp_2dgames.game.token.Laser;
import jp_2dgames.game.token.Cursor;
import jp_2dgames.game.particle.ParticleSmoke;
import flixel.util.FlxColor;
import jp_2dgames.game.item.InventoryUI;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.particle.ParticleNumber;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.save.Save.LoadType;
import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.game.save.Save;
import flixel.FlxSprite;
import jp_2dgames.game.actor.Player;
import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.game.global.Global;
import flixel.FlxState;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _bg:Bg;
  var _player:Player;
  var _seq:SeqMgr;

  var _state:State = State.Init;

  public var player(get, never):Player;
  public var seq(get, never):SeqMgr;
  public var bg(get, never):Bg;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 初期化
    Global.initLevel();

    // 背景の作成
    _bg = new Bg();
    this.add(_bg);
    Field.loadLevel(Global.level);
    var layer = Field.getLayer();
    Field.createBackground(layer, _bg);

    // カーソル生成
    Cursor.createInstance(this);

    // アイテム生成
    DropItem.createParent(this);
    Heart.createParent(this);

    // プレイヤー生成
    _player = new Player();
    this.add(_player.light);
    this.add(_player);

    // 敵生成
    Enemy.createParent(this);

    // パーティクル
    Particle.createParent(this);
    ParticleMessage.createParent(this);
    ParticleNumber.createParent(this);
    ParticleSmoke.createParent(this);
    Laser.createInstance(this);
    Bullet.createParent(this);

    // UI
    this.add(new GameUI());
    this.add(new InventoryUI());

    // プレイヤーの初期位置を設定
    {
      var pt = Field.getStartPosition();
      var prm = new Params();
      prm.id = 0;
      prm.hp = Std.int(Global.life);
      _player.init(Std.int(pt.x), Std.int(pt.y), Dir.Down, prm);
    }
    // 敵とアイテムの配置
    Field.createObjects();

    // シーケンス管理
    _seq = new SeqMgr(_player);

    // フェード開始
    FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    DropItem.destroyParent();
    Heart.destroyParent();
    Enemy.destroyParent();
    Particle.destroyParent();
    ParticleMessage.destroyParent();
    ParticleNumber.destroyParent();
    ParticleSmoke.destroyParent();
    Laser.destroyInstance();
    Bullet.destroyParent();
    Cursor.destroyInstance();

    super.destroy();
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

      case State.Gameover:
        if(Input.press.A) {
          // やり直し
//          FlxG.switchState(new PlayInitState());
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
    // ステージ開始演出
    var fontsize = 16 * 2;
    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, 'LEVEL ${Global.level}', fontsize);
    if(Global.level == Global.MAX_LEVEL-1) {
      txt.text = "FINAL LEVEL";
    }
    txt.setFormat(null, fontsize, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    var px = txt.x;
    txt.x = -FlxG.width*0.75;
    FlxTween.tween(txt, {x:px}, 1, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
      var px2 = FlxG.width * 0.75;
      FlxTween.tween(txt, {x:px2}, 1, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
        txt.visible = false;
      }});
    }});
    txt.scrollFactor.set();
    this.add(txt);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    switch(_seq.update()) {
      case SeqMgr.RET_NONE:
        // 何もなし
      case SeqMgr.RET_GAMEOVER:
        // ゲームオーバー
        FlxG.camera.shake(0.05, 0.4);
        FlxG.camera.flash(FlxColor.WHITE, 0.5);
        this.add(new GameoverUI(true));
        _state = State.Gameover;
    }
  }

  // -----------------------------------------------
  // ■アクセサ
  function get_player() {
    return _player;
  }
  function get_seq() {
    return _seq;
  }
  function get_bg() {
    return _bg;
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
    if(FlxG.keys.justPressed.S) {
      // セーブ
      Save.save(true, true);
    }
    if(FlxG.keys.justPressed.A) {
      // ロード
      Save.load(LoadType.All, true, true);
    }
  }

}
