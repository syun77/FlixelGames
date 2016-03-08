package jp_2dgames.game.token;

import jp_2dgames.lib.Input;
/**
 * カーソル
 **/
class Cursor extends Token {

  // -------------------------------------------------------
  // ■フィールド
  var _enable:Bool;
  public var enable(get, never):Bool;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    _enable = false;
    loadGraphic(AssetPaths.IMAGE_CURSOR, true);
    animation.add('${true}', [0], 1);
    animation.add('${false}', [1], 1);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var s = Field.GRID_SIZE;
    x = Std.int(Input.mouse.x/s) * s;
    y = Std.int(Input.mouse.y/s) * s;

    _enable = true;
    if(Infantry.isPutting(x, y)) {
      _enable = false;
    }
    if(Field.isPassage(x, y)) {
      _enable = false;
    }

    animation.play('${_enable}');
  }


  function get_enable() {
    return _enable;
  }
}
