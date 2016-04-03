package jp_2dgames.game.token;

import flixel.graphics.frames.FlxAtlasFrames;
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

  // ------------------------------------------------------
  // ■フィールド
  var _eid:Int;
  var _size:Float;
  var _width:Float;
  var _height:Float;

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

    var sprite_name = "nasu.png";

    // TexturePackerData is a helper class to store links to atlas image and atlas data files
    var tex = FlxAtlasFrames.fromTexturePackerJson("assets/images/enemy.png", "assets/images/enemy.json");
    frames = tex;
    animation.frameName = sprite_name;
    var frame = tex.getByName(sprite_name);
    _width = frame.frame.width;
    _height = frame.frame.height;

    x = X - _width/2;
    y = Y - _height/2;
    setVelocity(deg, speed);
  }



  // ------------------------------------------------------------
  // ■アクセサ
  override public function get_xcenter() {
    trace(super.get_xcenter());
    return x + _width/2;
  }

  override public function get_ycenter() {
    trace(super.get_ycenter());
    return y + _height/2;
  }
}
