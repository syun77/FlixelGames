package jp_2dgames.game.actor;

import flixel.math.FlxMath;
import jp_2dgames.lib.MyShake;
import flixel.FlxG;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import flixel.FlxSprite;

/**
 * アクター
 **/
class Actor extends FlxSprite {

  // ■定数
  // 揺れタイマー
  static inline var TIMER_SHAKE:Int = 120;


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

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    _params = new Params();
  }

  /**
   * 初期化
   **/
  public function init(p:Params):Void {
    _params.copy(p);

    visible = false;
    if(_params.id == 0) {
      _name = "プレイヤー";
      _group = BtlGroup.Player;
    }
    else {
      _name = "敵";
      _group = BtlGroup.Enemy;
      visible = true;
      // TODO:
      var path = AssetPaths.getEnemyImage("e001a");
      loadGraphic(path);

      // 位置を調整
      x = FlxG.width/2 - width/2;
      y = FlxG.height/2 - height;
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

    if(_group == BtlGroup.Player) {
      Message.push2(Msg.DAMAGE_PLAYER, [_name, v]);

      var v = FlxMath.lerp(0.01, 0.05, hpratio);
      FlxG.camera.shake(v, 0.1 + (v * 10));
    }
    else {
      Message.push2(Msg.DAMAGE_ENEMY, [_name, v]);
      shake(hpratio);
    }
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
}
