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
   * 座標を設定
   **/
  override public function setPosition(X:Float=.0, Y:Float=.0):Void {
    var s = Field.GRID_SIZE;
    var px = Std.int(X/s) * s;
    var py = Std.int(Y/s) * s;
    super.setPosition(px, py);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

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
