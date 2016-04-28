package jp_2dgames.game.actor;

import flixel.FlxSprite;

/**
 * アクター
 **/
class Actor extends FlxSprite {

  var _params:Params;

  public var params(get, never):Params;
  public var id(get, never):Int;
  public var hp(get, never):Int;
  public var hpmax(get, never):Int;
  public var str(get, never):Int;
  public var vit(get, never):Int;
  public var agi(get, never):Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(32, 32);
    _params = new Params();
  }

  /**
   * 初期化
   **/
  public function init(p:Params):Void {
    _params.copy(p);

    visible = (isPlayer() == false);
    trace(visible);
  }

  /**
   * プレイヤーキャラクターかどうか
   **/
  public function isPlayer():Bool {
    return id == 0;
  }

  // ---------------------------------------
  // ■アクセサ
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
