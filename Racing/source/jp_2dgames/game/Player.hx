package jp_2dgames.game;
import flixel.util.FlxAngle;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends FlxSprite {

  public static inline var SIZE:Float = 8;
  static inline var DECAY_ROLL = 0.01;

  public var left(get, never):Float;
  private function get_left() {
    return x;
  }
  public var right(get, never):Float;
  private function get_right() {
    return x + width;
  }
  // 中心座標(X)
  public var xcenter(get, never):Float;
  private function get_xcenter() {
    return x + origin.x;
  }
  // 中心座標(Y)
  public var ycenter(get, never):Float;
  private function get_ycenter() {
    return y + origin.y;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(Reg.PATH_IMAGE_CAR_RED);

    angle = -90;

    velocity.y = -100;
  }

  /**
   * 旋回する
   **/
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

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(Wall.clip(this)) {
      // 壁に衝突
      kill();
    }
  }
}
