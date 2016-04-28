package jp_2dgames.game.actor;

import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.lib.MyColor;
import flixel.FlxSprite;

/**
 * アクター
 **/
class Actor extends FlxSprite {

  var _name:String;
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
    makeGraphic(32, 32, MyColor.GRAY);
    _params = new Params();
  }

  /**
   * 初期化
   **/
  public function init(p:Params):Void {
    _params.copy(p);

    visible = (isPlayer() == false);
    if(isPlayer()) {
      _name = "プレイヤー";
    }
    else {
      _name = "敵";
    }
  }

  /**
   * プレイヤーキャラクターかどうか
   **/
  public function isPlayer():Bool {
    return id == 0;
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

    if(isPlayer()) {
      Message.push2(Msg.DAMAGE_PLAYER, [_name, v]);
    }
    else {
      Message.push2(Msg.DAMAGE_ENEMY, [_name, v]);
    }
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
