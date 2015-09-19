package jp_2dgames.game;
import flixel.util.FlxAngle;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends FlxSprite {

  static inline var DECAY_ROLL = 0.01;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(Reg.PATH_IMAGE_CAR_RED);

    angle = -90;

    velocity.y = -100;
  }

  public function roll(d:Float):Void {
    d *= DECAY_ROLL;
    var vx = velocity.x;
    var vy = velocity.y;
    var speed = Math.sqrt(vx*vx + vy*vy);
    var rot = Math.atan2(vy, vx) * FlxAngle.TO_DEG;
    rot += d;
    angle = rot;
    var radian = angle * FlxAngle.TO_RAD;
    velocity.x = speed * Math.cos(radian);
    velocity.y = speed * Math.sin(radian);
  }
}
