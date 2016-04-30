package jp_2dgames.game.actor;

import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyColor;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.particle.ParticleNumber;
import flixel.math.FlxMath;
import flixel.FlxG;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import flixel.FlxSprite;

/**
 * アクター
 **/
class Actor extends FlxEffectSprite {

  // ■定数
  // 揺れタイマー
  static inline var TIMER_SHAKE:Int = 120;

  // 元のスプライト
  var _spr:FlxSprite;
  // エフェクト
  var _eftWave:FlxWaveEffect;
  var _eftGlitch:FlxGlitchEffect;

  // ダメージ時の揺れ
  var _tShake:Float = 0.0;
  // アニメーションタイマー
  var _tAnime:Int = 0;

  var _group:BtlGroup;
  var _xstart:Float;

  var _name:String;
  var _params:Params;

  public var group(get, never):BtlGroup;
  public var params(get, never):Params;
  public var id(get, never):Int;
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
//    _params.copy(p);
    // 参照を保持する
    _params = p;

    visible = false;
    if(_params.id == 0) {
      _name = "プレイヤー";
      _group = BtlGroup.Player;

      // 位置を調整
      var rect = BattleUI.getPlayerHpRect();
      x = rect.x;
      y = rect.y;
      width = rect.width;
      height = rect.height;
      y -= height;
      rect.put();
    }
    else {
      _name = "敵";
      _group = BtlGroup.Enemy;
      visible = true;
      // TODO:
      var path = AssetPaths.getEnemyImage("e001a");
      _spr.loadGraphic(path);

      // 位置を調整
      x = FlxG.width/2 - _spr.width/2;
      y = FlxG.height/2 - _spr.height;

      // エフェクト開始
      _eftGlitch.active = false;
      _eftWave.strength = 100;
      _eftWave.wavelength = 2;
      FlxTween.tween(_eftWave, {strength:0}, 0.5, {ease:FlxEase.expoOut});
      color = 0;
      FlxTween.color(this, 0.5, FlxColor.BLACK, FlxColor.WHITE);
      _spr.alpha = 0;
      FlxTween.tween(_spr, {alpha:1}, 0.5);
    }
    _xstart = x;
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
   * 死亡したかどうか
   **/
  public function isDead():Bool {
    return hp <= 0;
  }

  /**
   * 警告状態かどうか
   **/
  public function isWarning():Bool {
    // 50%以下で警告とみなす
    return hpratio <= 0.5;
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    // 30%以下で危険とみなす
    return hpratio <= 0.3;
  }

  /**
   * 名前を取得
   **/
  public function getName():String {
    return _name;
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Void {
    _params.hp -= v;
    if(_params.hp < 0) {
      _params.hp = 0;
    }

    var w = width;
    var h = height;
    var ratio = v / hpmax;
    if(_group == BtlGroup.Player) {
      // プレイヤー
      Message.push2(Msg.DAMAGE_PLAYER, [_name, v]);

      var v = FlxMath.lerp(0.01, 0.05, ratio);
      FlxG.camera.shake(v, 0.1 + (v * 10));
    }
    else {
      // 敵
      Message.push2(Msg.DAMAGE_ENEMY, [_name, v]);
      shake(ratio);
      w = _spr.width;
      h = _spr.height;

      // TODO: 死亡エフェクト
      if(isDead()) {
        _eftGlitch.active = true;
        FlxTween.tween(_eftGlitch, {strength:100}, 0.5, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
          _eftGlitch.strength = 0;
          visible = false;
        }});
      }
    }
    var px = x + w/2;
    var py = y + h/2;
    ParticleNumber.start(px, py, v);
    Particle.start(PType.Ball, px, py, FlxColor.RED);
  }

  /**
   * HP回復
   **/
  public function recover(v:Int):Void {
    _params.hp += v;
    if(_params.hp > hpmax) {
      _params.hp = hpmax;
    }

    var w = width;
    var h = height;
    if(_group == BtlGroup.Player) {
    }
    else {
      w = _spr.width;
      h = _spr.height;
    }

    var px = x + w/2;
    var py = y + h/2;
    ParticleNumber.start(px, py, v, MyColor.LIME);
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

  /**
   * 揺らす
   **/
  private function _updateShake():Void {
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

  // ---------------------------------------
  // ■アクセサ
  function get_group() {
    return _group;
  }
  function get_params() {
    return _params;
  }
  function get_id() {
    return _params.id;
  }
  function get_hp() {
    return _params.hp;
  }
  function get_hpmax() {
    return _params.hpmax;
  }
  function get_hpratio() {
    return hp / hpmax;
  }
  function get_str() {
    return _params.str;
  }
  function get_vit() {
    return _params.vit;
  }
  function get_agi() {
    return _params.agi;
  }
  function get_food() {
    return _params.food;
  }
}
