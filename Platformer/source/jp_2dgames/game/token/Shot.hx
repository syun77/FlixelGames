package jp_2dgames.game.token;

import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;

/**
 * ショット
 **/
class Shot extends Token {

  public static var parent:TokenMgr<Shot> = null;

  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr(32, Shot);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }

  public static function add(X:Float, Y:Float, deg:Float, speed:Float):Shot {
    var s:Shot = parent.recycle();
    s.init(X, Y, deg, speed);
    return s;
  }

  public static function countExist():Int {
    return parent.countLiving();
  }

  var _tDestroy:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHOT, true);
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

    _tDestroy = 90;
  }

  public override function update():Void {
    super.update();
    _tDestroy--;
    if(_tDestroy < 1) {
      Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.AZURE);
      kill();
    }
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    FlxG.camera.shake(0.001, 0.1);

    Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.AZURE);
    kill();
  }
}
