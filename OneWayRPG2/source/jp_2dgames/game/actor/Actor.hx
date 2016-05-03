package jp_2dgames.game.actor;
import jp_2dgames.game.gui.BattleUI;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.game.dat.EnemyDB;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.FlxSprite;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;
import flixel.addons.effects.chainable.FlxEffectSprite;
import jp_2dgames.game.dat.MyDB;

/**
 * アクター
 **/
class Actor extends FlxEffectSprite {

  // タイマー
  static inline var TIMER_SHAKE:Int = 120; // 揺れタイマー

  // -------------------------------------------
  // ■フィールド
  var _name:String;    // 名前
  var _params:Params;  // パラメータ
  var _group:BtlGroup; // 敵か味方か

  // 演出用
  var _spr:FlxSprite;       // もとのスプライト
  var _xstart:Float = 0.0;  // 出現時のX座標
  var _tAnime:Float = 0.0;  // アニメーション用タイマー
  var _tShake:Float = 0.0;  // 揺れ用のタイマ
  // エフェクト
  var _eftWave:FlxWaveEffect;     // ゆらゆら
  var _eftGlitch:FlxGlitchEffect; // ゆがみ


  // アクセサ
  public var group(get, never):BtlGroup;
  public var params(get, never):Params;
  public var id(get, never):EnemiesKind;
  public var hp(get, never):Int;
  public var hpmax(get, never):Int;
  public var hpratio(get, never):Float;
  public var str(get, never):Int;
  public var vit(get, never):Int;
  public var agi(get, never):Int;
  public var food(get, never):Int;


  /**
   * コンストラクタ
   **/
  public function new() {
    _spr = new FlxSprite();
    super(_spr);

    _eftWave = new FlxWaveEffect();
    _eftGlitch = new FlxGlitchEffect();
    _eftGlitch.strength = 0;
    _eftGlitch.direction = FlxGlitchDirection.VERTICAL;
    effects = [_eftWave, _eftGlitch];

    _params = new Params();

  }

  /**
   * 初期化
   **/
  public function init(p:Params):Void {
    // 参照を保持する
    _params = p;
    if(p.id == EnemiesKind.Player) {
      // プレイヤー
      _initPlayer();
    }
    else {
      // 敵
      _initEnemy();
    }

    // 開始座標を保存
    _xstart = x;
  }

  /**
   * プレイヤーの初期化
   **/
  function _initPlayer():Void {
    _name = EnemyDB.getName(id);
    _group = BtlGroup.Player;
    visible = false;

    // 位置を調整
    var rect = BattleUI.getPlayerHpRect();
    x = rect.x;
    y = rect.y;
    width = rect.width;
    height = rect.height;
    y -= height;
    rect.put();
  }

  /**
   * 敵の初期化
   **/
  function _initEnemy():Void {
    var p = _params;
    _group = BtlGroup.Enemy;
    _name = EnemyDB.getName(p.id);
    _params.str = EnemyDB.getAtk(p.id);
    _params.setHpMax(EnemyDB.getHp(p.id));

    // 敵画像読み込み
    var path = AssetPaths.getEnemyImage(EnemyDB.getImage(p.id));
    _spr.loadGraphic(path);
    visible = true;

    // 位置を調整
    x = FlxG.width/2 - _spr.width/2;
    y = FlxG.height/2 - _spr.height;

    // 出現エフェクト開始
    _eftGlitch.active = false;
    _eftWave.strength = 100;
    _eftWave.wavelength = 2;
    FlxTween.tween(_eftWave, {strength:0}, 0.5, {ease:FlxEase.expoOut});
    color = 0;
    FlxTween.color(this, 0.5, FlxColor.BLACK, FlxColor.WHITE);
    _spr.alpha = 0;
    FlxTween.tween(_spr, {alpha:1}, 0.5);

  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnime++;

    _updateShake();
  }

  /**
   * 更新・揺らす
   **/
  function _updateShake():Void {
    if(_group != BtlGroup.Enemy) {
      return;
    }

    x = _xstart;
    if(_tShake > 0) {
      _tShake *= 0.9;
      if(_tShake < 1) {
        _tShake = 0;
      }
      var xsign = if(_tAnime%4 < 2) 1 else -1;
      x = _xstart + (_tShake * xsign * 0.2);
    }
  }

  /**
   * 名前を取得
   **/
  public function getName():String {
    return _name;
  }

  /**
   * 死亡したかどうか
   **/
  public function isDead():Bool {
    return hp <= 0;
  }

  /**
   * 警告状態かどうか
   **/
  public function isWarning():Bool {
    // 60%以下で警告とみなす
    return hpratio <= 0.6;
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    // 40%以下で危険とみなす
    return hpratio <= 0.4;
  }

  /**
   * 食糧を増やす
   **/
  public function addFood(v:Int):Void {
    _params.food += v;
    if(_params.food > 99) {
      _params.food = 99;
    }
  }

  /**
   * 食糧を減らす
   **/
  public function subFood(v:Int):Bool {
    _params.food -= v;
    if(_params.food < 0) {
      _params.food = 0;
      // 食糧が足りない
      return false;
    }

    // 食糧が残っていた
    return true;
  }
  /**
   * 揺らす
   **/
  public function shake(ratio:Float=1.0):Void {
    _tShake = Std.int(TIMER_SHAKE * ratio);
  }



  // -------------------------------------------
  // ■アクセサメソッド
  function get_group() { return _group; }
  function get_params() { return _params; }
  function get_id() { return _params.id; }
  function get_hp() { return _params.hp; }
  function get_hpmax() { return _params.hpmax; }
  function get_hpratio() { return hp / hpmax; }
  function get_str() { return _params.str; }
  function get_vit() { return _params.vit; }
  function get_agi() { return _params.agi; }
  function get_food() { return _params.food; }

}
