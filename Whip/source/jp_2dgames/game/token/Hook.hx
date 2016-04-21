package jp_2dgames.game.token;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ロープをひっかける場所
 **/
class Hook extends Token {

  public static var parent:FlxTypedGroup<Hook> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Hook>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Hook {
    var hook = parent.recycle(Hook);
    hook.init(X, Y);
    return hook;
  }

  // ----------------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_HOOK);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }

  // -----------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 8;
  }
}
