package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 砲台
 **/
class Infantry extends Token {

  static inline var TIMER_COOLDOWN:Float = 1.0;

  public static var parent:FlxTypedGroup<Infantry> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Infantry>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Infantry {
    var infantry = parent.recycle(Infantry);
    infantry.init(X, Y);
    return infantry;
  }

  // -------------------------------------------------------------------
  // ■フィールド
  var _tCooldown:Float;


  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_INFANTRY);
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _tCooldown = 0;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 一番近くにいる敵の方向を向く
    _lookEnemy();

    // 弾を撃つ
    _tCooldown -= elapsed;
    _shot();
  }

  /**
   * 敵がいる方向を向く
   **/
  function _lookEnemy():Void {

    // 一番近くにいる敵を取得する
    var enemy = Enemy.getNearest(this);
    if(enemy == null) {
      // 敵がいない
      return;
    }

    var dx = enemy.xcenter - xcenter;
    var dy = enemy.ycenter - ycenter;
    var aim = 360 - MyMath.atan2Ex(-dy, dx);
    var d = MyMath.deltaAngle(angle, aim);
    angle += d * 0.1;
  }

  /**
   * 弾を撃つ
   **/
  function _shot():Void {
    if(_tCooldown > 0) {
      // 撃てない
      return;
    }

    Shot.add(xcenter, ycenter, 360 - angle, 100);
    _tCooldown = TIMER_COOLDOWN;
  }
}
