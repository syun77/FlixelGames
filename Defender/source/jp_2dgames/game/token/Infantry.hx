package jp_2dgames.game.token;

import flixel.math.FlxMath;
import jp_2dgames.lib.MyMath;
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
  public static function isPutting(X:Float, Y:Float):Bool {
    return getFromPosition(X, Y) != null;
  }
  public static function getFromPosition(X:Float, Y:Float):Infantry {
    var ret:Infantry = null;
    var x1 = Std.int(X);
    var y1 = Std.int(Y);
    parent.forEachAlive(function(infantry:Infantry) {
      var x2 = Std.int(infantry.x);
      var y2 = Std.int(infantry.y);
      if(x1 == x2 && y1 == y2) {
        ret = infantry;
      }
    });
    return ret;
  }

  // -------------------------------------------------------------------
  // ■フィールド
  var _tCooldown:Float;

  // 一番近い敵との角度差
  var _dAngleNearestEnemy:Float;

  // 一番近い敵との距離
  var _dDistanceNearestEnemy:Float;

  // パラメータ
  var _range:Int;      // 射程範囲
  var _power:Int;      // 攻撃威力
  var _firerate:Float; // 攻撃間隔

  public var range(get, never):Int;
  public var power(get, never):Int;
  public var firerate(get, never):Float;


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
    _dAngleNearestEnemy = 999;

    _range = 32;
    _power = 1;
    _firerate = 2.0;
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

    // 距離を取得
    _dDistanceNearestEnemy = FlxMath.distanceBetween(this, enemy);
    if(_dDistanceNearestEnemy > range) {
      // 射程範囲外
      return;
    }

    var dx = enemy.xcenter - xcenter;
    var dy = enemy.ycenter - ycenter;
    var aim = 360 - MyMath.atan2Ex(-dy, dx);
    var d = MyMath.deltaAngle(angle, aim);
    angle += d * 0.1;
    _dAngleNearestEnemy = d;
  }

  /**
   * 弾を撃つ
   **/
  function _shot():Void {
    if(_tCooldown > 0) {
      // 撃てない
      return;
    }

    if(Math.abs(_dAngleNearestEnemy) > 5) {
      // 撃てない
      return;
    }
    if(_dDistanceNearestEnemy > range) {
      // 射程範囲外
      return;
    }

    Shot.add(xcenter, ycenter, 360 - angle, 100);
    _tCooldown = _firerate;
  }


  // ---------------------------------------
  // ■アクセサ
  function get_range() {
    return _range;
  }
  function get_power() {
    return _power;
  }
  function get_firerate() {
    return _firerate;
  }
}
