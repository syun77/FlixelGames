package jp_2dgames.game.token;

import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;

/**
 * 敵弾
 **/
class Bullet extends Token {

  public static var parent:TokenMgr<Bullet> = null;

  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr(32, Bullet);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }

  public static function add(X:Float, Y:Float, deg:Float, speed:Float):Bullet {
    var s:Bullet = parent.recycle();
    s.init(X, Y, deg, speed);
    return s;
  }

  public static function countExist():Int {
    return parent.countLiving();
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BULLET, true);
    animation.add("play", [0, 1], 8);
    animation.play("play");
    kill();
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

    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.RED);
    kill();
  }
}
