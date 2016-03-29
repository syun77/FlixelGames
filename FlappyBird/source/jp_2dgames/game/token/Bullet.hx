package jp_2dgames.game.token;

import flash.display.BlendMode;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 敵弾
 **/
class Bullet extends Token {

  public static var parent:FlxTypedGroup<Bullet> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Bullet>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(attr:Attribute, X:Float, Y:Float, deg:Float, speed:Float):Bullet {
    var b = parent.recycle(Bullet);
    b.init(attr, X, Y, deg, speed);
    return b;
  }

  // ---------------------------------------------------------------
  // ■フィールド
  var _attr:Attribute;
  public var attribute(get, never):Attribute;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BULLET, true);
    animation.add("play", [0, 1], 8);
    animation.play("play");
    blend = BlendMode.ADD;
  }

  /**
   * 初期化
   **/
  public function init(attr:Attribute, X:Float, Y:Float, deg:Float, speed:Float):Void {
    _attr = attr;
    x = X - width/2;
    y = Y - height/2;
    setVelocity(deg, speed);
    color = AttributeUtil.toColor(_attr);
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball2, xcenter, ycenter, color);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(isOutside()) {
      // 画面外に出たら消える
      kill();
    }
  }

  // ----------------------------------------------------------------
  // ■アクセサ
  function get_attribute() {
    return _attr;
  }
}
