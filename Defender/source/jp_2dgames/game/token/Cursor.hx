package jp_2dgames.game.token;

/**
 * カーソル
 **/
import jp_2dgames.lib.Input;
class Cursor extends Token {
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_CURSOR);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var s = Field.GRID_SIZE;
    x = Std.int(Input.mouse.x/s) * s;
    y = Std.int(Input.mouse.y/s) * s;
  }

}
