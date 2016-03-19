package jp_2dgames.game.token;

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

  // --------------------------------
  // ■フィールド
  var _onerect:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 一マスカーソルの生成
    _onerect = new FlxSprite();
    _onerect.loadGraphic(AssetPaths.IMAGE_CURSOR, true);
    _onerect.animation.add("play", [0, 1], 8);
    _onerect.animation.play("play");
    _onerect.kill();
    this.add(_onerect);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _updatePosition();
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
