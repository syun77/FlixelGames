package jp_2dgames.game.token;

/**
 * 拠点
 **/
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
class Flag extends Token {
  public function new(X:Float, Y:Float) {
    X -= 8;
    Y -= 8;
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_FLAG);
  }

  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.YELLOW);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.YELLOW);
    kill();
  }

  override public function get_radius():Float {
    return 4;
  }
}
