package jp_2dgames.game.token;

/**
 * 射程範囲の表示
 **/
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
class RangeOfView extends Token {
  public function new() {
    super();
    visible = false;
  }

  public function updateView(cursor:Cursor, range:Int):Void {
    makeGraphic(range*2, range*2, FlxColor.TRANSPARENT);
    setPos(cursor);

    FlxSpriteUtil.drawCircle(this, range, range, range);
    visible = true;
    alpha = 0.2;
    trace("update view");
  }

  public function setPos(cursor:Cursor):Void {
    setPosition(cursor.xcenter - width/2, cursor.ycenter - height/2);
  }

  public function hide():Void {
    visible = false;
  }
}
