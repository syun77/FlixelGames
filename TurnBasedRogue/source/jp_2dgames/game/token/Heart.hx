package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ハート(回復アイテム)
 **/
class Heart extends Token {

  public static var parent:FlxTypedGroup<Heart> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Heart>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(xc:Int, yc:Int):Heart {
    var heart = parent.recycle(Heart);
    heart.init(xc, yc);
    return heart;
  }

  /**
   * 足下にあるアイテムを拾う
   **/
  public static function pickup(xc:Int, yc:Int):Void {
    parent.forEachAlive(function(heart:Heart) {
      if(heart.xchip == xc && heart.ychip == yc) {
        // ハート取得
        heart._gain();
      }
    });
  }

  // --------------------------------------------------
  // ■フィールド
  var _xchip:Int;
  var _ychip:Int;
  public var xchip(get, never):Int;
  public var ychip(get, never):Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    loadGraphic(AssetPaths.IMAGE_HEART, true);
    animation.add("play", [0], 1);
    animation.play("play");
  }

  /**
   * 初期化
   **/
  public function init(xc:Int, yc:Int):Void {
    _xchip = xc;
    _ychip = yc;
    x = Field.toWorldX(xc);
    y = Field.toWorldY(yc);
  }

  /**
   * 取得する
   **/
  function _gain():Void {
    SeqMgr.recoverTurn(Consts.RECOVER_HEART);
    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.LIME);
    kill();
  }

  // ---------------------------------------------------
  // ■アクセサ
  function get_xchip() {
    return _xchip;
  }
  function get_ychip() {
    return _ychip;
  }
}
