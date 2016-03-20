package jp_2dgames.game.token;

import flash.display.BlendMode;
import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 弾の種類
 **/
enum BulletType {
  Horizon; // 水平方向
  Vertical; // 垂直方向
}

/**
 * 敵の弾
 **/
class Bullet extends Token {

  public static var parent:FlxTypedGroup<Bullet> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Bullet>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:BulletType, xc:Int, yc:Int):Bullet {
    var b = parent.recycle(Bullet);
    b.init(type, xc, yc);
    return b;
  }

  // ----------------------------------------------------
  // ■フィールド
  var _type:BulletType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    blend = BlendMode.ADD;
    alpha = 0.5;
  }

  /**
   * 初期化
   **/
  public function init(type:BulletType, xc:Int, yc:Int):Void {
    x = Field.toWorldX(xc);
    y = Field.toWorldY(yc);
    switch(type) {
      case BulletType.Horizon:
        makeGraphic(FlxG.width*2, Field.GRID_SIZE, MyColor.AQUAMARINE);
        x -= FlxG.width;
      case BulletType.Vertical:
        makeGraphic(Field.GRID_SIZE, FlxG.height*2, MyColor.AQUAMARINE);
        y -= FlxG.height;
    }
    _type = type;

    scale.set(1, 1);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_type) {
      case BulletType.Horizon:
        scale.y *= 0.9;
      case BulletType.Vertical:
        scale.x *= 0.9;
    }

    if(scale.x < 0.01 || scale.y < 0.01) {
      kill();
    }
  }
}
