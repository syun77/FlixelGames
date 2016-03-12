package jp_2dgames.game.token;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * 背景
 **/
class Bg extends FlxSpriteGroup {

  /**
   * コンストラクタ
   **/
  public function new() {

    var xofs = Field.xofs;
    var yofs = Field.yofs;
    super(xofs, yofs);

    var grid = new FlxSprite();
    var w = Field.GRID_WIDTH+1;
    var h = Field.GRID_HEIGHT+1;
    grid.makeGraphic(w, h, FlxColor.TRANSPARENT);
    this.add(grid);

    // グリッド線を引く
    for(i in 0...Field.WIDTH+1) {
      var x = i * Field.GRID_SIZE;
      FlxSpriteUtil.drawLine(grid, x, 0, x, h);
    }
    for(j in 0...Field.HEIGHT+1) {
      var y = j * Field.GRID_SIZE;
      FlxSpriteUtil.drawLine(grid, 0, y, w, y);
    }

    alpha = 0.2;
  }
}
