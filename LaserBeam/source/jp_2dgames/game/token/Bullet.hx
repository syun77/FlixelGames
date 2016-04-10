package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
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
  public static function add(X:Float, Y:Float, deg:Float, speed:Float):Bullet {
    var b = parent.recycle(Bullet);
    b.init(X, Y, deg, speed);
    return b;
  }

  // ----------------------------------------------------------
  // ■フィールド


  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BULLET);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, deg:Float, speed:Float):Void {
    x = X - width/2;
    y = Y - height/2;
    setVelocity(deg, speed);
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.RED);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(isOutside()) {
      kill();
    }
  }


  // -----------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 8;
  }

}
