package jp_2dgames.game.token;
/**
 * 鉄球
 **/
import jp_2dgames.lib.Snd;
import flixel.FlxG;
import flixel.FlxState;
class Spike extends Token {

  public static var parent:TokenMgr<Spike> = null;

  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr(64, Spike);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }

  public static function add(X:Float, Y:Float):Spike {
    var spike = parent.recycle();
    spike.init(X, Y);

    return spike;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_CHARSET, true, CharSet.WIDTH, CharSet.HEIGHT);
    var anim = [for(i in 0...4) CharSet.OFS_SPIKE3+i];
    animation.add("play", anim, 8);
    animation.play("play");
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    Global.addScore(100);
//    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.BROWN);
    FlxG.camera.shake(0.01, 0.2);
    kill();
    Snd.playSe("explosion", true);

    for(i in 0...8) {
      var deg = i * 45;
      var spd = 100;
      Bullet.add(xcenter, ycenter, deg, spd);
    }
  }
}
