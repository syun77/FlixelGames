package jp_2dgames.game.token;

/**
 * スクロールオブジェクト
 **/
import flixel.FlxG;
class ScrollObj extends Token {
  public function new(X:Float, Y:Float) {
    super(X, Y);
    visible = false;
  }

  /**
   * 速度を設定
   **/
  public function setSpeed(spd:Float):Void {
    var d = -(velocity.y + spd);
    velocity.y += d * 0.1;

    // 速度制限
    if(velocity.y < -200) {
      velocity.y = -200;
    }
    if(velocity.y > -50) {
      velocity.y = -50;
    }
  }
}
