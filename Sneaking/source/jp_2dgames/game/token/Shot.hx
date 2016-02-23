package jp_2dgames.game.token;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

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

  // ---------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(4, 4, FlxColor.WHITE);
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
    kill();
  }
}
