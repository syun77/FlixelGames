package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ショット
 **/
class Shot extends Token {

  public static var parent:FlxTypedGroup<Shot> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Shot>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, deg:Float, speed:Float):Shot {
    var shot = parent.recycle(Shot);
    shot.init(X, Y, deg, speed);
    return shot;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHOT, true);
    animation.add("play", [0, 1], 4);
    animation.play("play");
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
    Particle.start(PType.Ball2, xcenter, ycenter, FlxColor.WHITE);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(isOutside()) {
      // 画面外に出たので消す
      kill();
    }
  }

  // --------------------------------------------------
  // ■アクセサ

  override public function get_radius():Float {
    return 16;
  }
}
