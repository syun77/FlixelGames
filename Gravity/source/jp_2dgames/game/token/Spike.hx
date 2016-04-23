package jp_2dgames.game.token;
import jp_2dgames.lib.DirUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

/**
 * 鉄球
 **/
class Spike extends Token {

  static inline var SPEED:Float = 50.0;

  public static var parent:FlxTypedGroup<Spike> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Spike>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(dir:Dir, X:Float, Y:Float):Spike {
    var spike:Spike = parent.recycle(Spike);
    spike.init(dir, X, Y);
    return spike;
  }

  // ----------------------------------------------------------------------
  // ■フィールド
  // 移動方向
  var _dir:Dir;
  public var dir(get, never):Dir;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SPIKE, true);
    animation.add('${Dir.None}', [0, 1, 2, 3], 8); // 動かない
    animation.add('${Dir.Up}', [4, 5, 6, 7], 8);
    animation.add('${Dir.Down}', [4, 5, 6, 7], 8);
    animation.add('${Dir.Left}', [8, 9, 10, 11], 8);
    animation.add('${Dir.Right}', [8, 9, 10, 11], 8);
  }

  /**
   * 初期化
   **/
  public function init(dir:Dir, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _dir = dir;
    animation.play('${_dir}');

    _setVelocity();
  }

  /**
   * 移動方向を反転する
   **/
  public function reverse():Void {
    _dir = DirUtil.reverse(_dir);
    _setVelocity();
  }

  function _setVelocity():Void {
    var pt = DirUtil.getVector(_dir);
    velocity.set(pt.x*SPEED, pt.y*SPEED);
    pt.put();
  }


  // --------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 8;
  }
  function get_dir() {
    return _dir;
  }
}
