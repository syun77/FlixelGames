package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import flixel.math.FlxPoint;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyColor;
import jp_2dgames.lib.DirUtil;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 加速矢印
 **/
class Arrow extends Token {

  // 反動
  public static inline var REACT_SPEED:Float = 100.0;

  public static var parent:FlxTypedGroup<Arrow> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Arrow>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, direction:Dir):Arrow {
    var arrow = parent.recycle(Arrow);
    arrow.init(X, Y, direction);
    return arrow;
  }

  // --------------------------------------------------------------
  // ■フィールド
  var _dir:Dir;
  public var dir(get, never):Dir;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ARROW, true);
    _regisiterAnim();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, direction:Dir):Void {
    x = X;
    y = Y;
    _dir = direction;
    animation.play('${_dir}');
  }
  /**
   * 消滅
   **/
  public function vanish():Void {
    var c = MyColor.GRAY;
    Particle.start(PType.Ball2, xcenter, ycenter, c);
    Particle.start(PType.Ring2, xcenter, ycenter, c);
    Snd.playSe("pit", true);
    kill();
  }

  /**
   * 反動速度の取得
   **/
  public function getReactVelocity():FlxPoint {
    var pt = DirUtil.getVector(_dir);
    pt.x *= REACT_SPEED;
    pt.y *= REACT_SPEED;
    return pt;
  }

  function _regisiterAnim():Void {
    animation.add('${Dir.Left}',  [0], 1);
    animation.add('${Dir.Up}',    [1], 1);
    animation.add('${Dir.Right}', [2], 1);
    animation.add('${Dir.Down}',  [3], 1);
  }

  // -------------------------------------------------------------
  // ■アクセサ
  function get_dir() {
    return _dir;
  }
}
