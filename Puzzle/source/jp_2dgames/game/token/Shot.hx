package jp_2dgames.game.token;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;

/**
 * ショット
 **/
class Shot extends Token {
  static inline var MAX_SHOT:Int = 4;

  public static var parent:TokenMgr<Shot> = null;
  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr<Shot>(MAX_SHOT, Shot);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, deg:Float, speed:Float):Shot {
    if(countExists() >= MAX_SHOT) {
      // 撃てない
      return null;
    }

    var shot:Shot = parent.recycle();
    shot.init(X, Y, deg, speed);
    return shot;
  }
  public static function countExists():Int {
    return parent.countLiving();
  }
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
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.AZURE);
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, deg:Float, speed:Float):Void {
    x = X - width/2;
    y = Y - height/2;
    setVelocity(deg, speed);
    trace("shot",x, y, velocity.x, velocity.y);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(isOnScreen() == false) {
      // 画面外に出た
      vanish();
    }
  }
}
