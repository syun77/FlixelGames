package jp_2dgames.game.token;
import jp_2dgames.lib.DirUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import jp_2dgames.game.state.PlayState;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * プレイヤーが近づくと出現するトゲ
 **/
class Pit extends Token {

  public static var parent:FlxTypedGroup<Pit> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Pit>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(dir:Dir, X:Float, Y:Float):Pit {
    var pit = parent.recycle(Pit);
    pit.init(dir, X, Y);
    return pit;
  }

  // -----------------------------------------------
  // ■フィールド
  var _bLiftup:Bool; // 移動中かどうか
  var _dir:Dir; // 移動方向

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PIT);
  }

  /**
   * 初期化
   **/
  public function init(dir:Dir, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    xstart = x;
    ystart = y;

    _bLiftup = false;
    _dir = dir;
    angle = DirUtil.toAngle(_dir) * -1;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    super.update(elapsed);

    if(_bLiftup == false) {
      if(_checkLiftup()) {
        _liftup();
      }
    }

  }

  function _checkLiftup():Bool {
    var target = PlayState.player;

    switch(_dir) {
      case Dir.Up:
        if(target.y > y) {
          // ターゲットが下にいる
          return false;
        }
      case Dir.Left:
        if(target.x > x) {
          // ターゲットが右にいる
          return false;
        }
      case Dir.Right:
        if(target.x < x) {
          // ターゲットが左にいる
          return false;
        }
      default:
        throw 'Error: Invalid direction = ${_dir}';
    }
    var distance = FlxMath.distanceBetween(this, target);
    if(distance > Field.GRID_SIZE) {
      // 距離範囲外
      return false;
    }

    // 飛び出す
    return true;
  }

  function _liftup():Void {

    var tx = x;
    var ty = y;
    switch(_dir) {
      case Dir.Up:
        ty = y - Field.GRID_SIZE;
      case Dir.Left:
        tx = x - Field.GRID_SIZE;
      case Dir.Right:
        tx = x + Field.GRID_SIZE;
      default:
        throw 'Error: Invalid direction = ${_dir}';
    }

    _bLiftup = true;
    new FlxTimer().start(0.2, function(timer:FlxTimer) {
      FlxTween.tween(this, {x:tx, y:ty}, 0.5, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
        new FlxTimer().start(0.5, function(timer:FlxTimer) {
          FlxTween.tween(this, {x:xstart, y:ystart}, 0.5, {ease:FlxEase.expoOut});
            new FlxTimer().start(1, function(timer:FlxTimer) {
              _bLiftup = false;
            });
        });
      }});
    });
  }

  // -----------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 2;
  }
}
