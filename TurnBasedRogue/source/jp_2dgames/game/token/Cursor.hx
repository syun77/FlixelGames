package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.FlxState;
import jp_2dgames.lib.Input;
import flixel.group.FlxSpriteGroup;

/**
 * カーソル
 **/
class Cursor extends FlxSpriteGroup {

  static var _instance:Cursor = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new Cursor();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static var xchip(get, never):Int;
  public static var ychip(get, never):Int;
  public static function setVisibleOneRect(b:Bool):Void {
    if(b) {
      _instance._onerect.revive();
    }
    else {
      _instance._onerect.kill();
    }
  }
  public static function setVisibleRange3(b:Bool):Void {
    if(b) {
      _instance._range3.revive();
      _instance.visible = true;
    }
    else {
      _instance._range3.kill();
    }
  }
  public static function setBasePosition(x:Float, y:Float):Void {
    _instance.x = x;
    _instance.y = y;
  }

  // --------------------------------
  // ■フィールド
  var _onerect:FlxSprite;
  var _range3:FlxSprite;
  var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _timer = 0;

    // 一マスカーソルの生成
    _onerect = new FlxSprite();
    _onerect.loadGraphic(AssetPaths.IMAGE_CURSOR, true);
    _onerect.animation.add("play", [0, 1], 8);
    _onerect.animation.play("play");
    _onerect.kill();
    this.add(_onerect);

    // 3マスカーソルの生成
    _range3 = new FlxSprite();
    _range3.loadGraphic(AssetPaths.IMAGE_CURSOR3);
    _range3.x -= 3 * Field.GRID_SIZE;
    _range3.y -= 3 * Field.GRID_SIZE;
    _range3.blend = BlendMode.ADD;
    _range3.alpha = 0.2;
    _range3.kill();
    this.add(_range3);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_range3.exists == false) {
      _updatePosition();
    }

    _timer++;
    _range3.alpha = 0.2 + 0.1 * MyMath.sinEx(_timer*2);
  }

  /**
   * 更新・座標
   **/
  function _updatePosition():Void {
    var s = Field.GRID_SIZE;
    x = Std.int(Input.mouse.x/s) * s;
    y = Std.int(Input.mouse.y/s) * s;

    visible = true;
    if(x >= Field.getWidth()) {
      visible = false;
    }
  }

  // -------------------------------------------------------
  // ■アクセサ
  static function get_xchip() {
    return Std.int(_instance.x / Field.GRID_SIZE);
  }
  static function get_ychip() {
    return Std.int(_instance.y / Field.GRID_SIZE);
  }

}
