package jp_2dgames.game;
import jp_2dgames.lib.Snd;
import flixel.util.FlxColor;
import jp_2dgames.game.Particle.PType;
import flixel.util.FlxAngle;
import flixel.FlxSprite;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var DECAY_ROLL = 0.01;
  // 半径サイズ
  override public function get_radius() {
    return 8;
  }

  private var _speed:Float = 0;
  public function getSpeed():Float {
    return _speed;
  }

  private var _tFrame:Float = 0;
  private var _active:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    x -= width;
    loadGraphic(Reg.PATH_IMAGE_CAR_RED);

    angle = -90;
  }

  /**
   * 死亡演出
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.RED);
    kill();
    Snd.playSe("destroy2");
  }

  public function start():Void {
    _active = true;
    _speed = Reg.SPEED_INIT;
    velocity.y = -1;
  }

  public function addFrameTimer(v:Int):Void {
    _tFrame += v;
  }

  /**
   * 旋回する
   **/
  public function roll(d:Float):Void {
    if(_active == false) {
      return;
    }

    d *= DECAY_ROLL;
    var vx = velocity.x;
    var vy = velocity.y;
    var rot = Math.atan2(vy, vx) * FlxAngle.TO_DEG;
    rot += d;
    angle = rot;
    var radian = angle * FlxAngle.TO_RAD;
    velocity.x = _speed * Math.cos(radian);
    velocity.y = _speed * Math.sin(radian);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    if(_active == false) {
      return;
    }

    super.update();

    _tFrame++;
    _speed = Reg.SPEED_INIT + Math.sqrt(_tFrame * 0.0001) * 300;

    if(Wall.clip(this)) {
      // 壁に衝突
      vanish();
    }
  }
}
