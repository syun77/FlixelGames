package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 砲台
 **/
class Infantry extends Token {

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
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 一番近くにいる敵の方向を向く
    _lookEnemy();

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

    var aim = FlxAngle.angleBetween(this, enemy) * FlxAngle.TO_DEG;
    var d = MyMath.deltaAngle(angle, aim);
    angle += d * 0.1;
  }
}
