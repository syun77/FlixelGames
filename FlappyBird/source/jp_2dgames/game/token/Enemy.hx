package jp_2dgames.game.token;

import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 敵
 **/
class Enemy extends Token {

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Enemy {
    var e = parent.recycle(Enemy);
    e.init(eid, X, Y, deg, speed);
    return e;
  }


  // ----------------------------------------------------------
  // ■フィールド
  var _eid:Int;  // 敵ID
  var _hp:Int;   // HP
  var _size:Int; // 半径

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Void {
    _eid = eid;
    x = X;
    y = Y;
    setVelocity(deg, speed);
    _size = 16;
    makeGraphic(_size, _size, FlxColor.GREEN);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(isOutside()) {
      // 画面外に出たら消える
      kill();
    }
  }

  // ----------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return _size;
  }
}
