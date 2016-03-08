package jp_2dgames.game.gui;

import jp_2dgames.game.token.Infantry;
import jp_2dgames.game.token.Cursor;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * ヒントUI
 **/
class HintUI extends FlxSpriteGroup {

  var _txt:FlxText;
  var _cursor:Cursor;

  public function new(cursor:Cursor) {
    super(0, FlxG.height-12);

    _cursor = cursor;

    var bg = new FlxSprite();
    bg.makeGraphic(FlxG.width, 12, FlxColor.GRAY);
    bg.alpha = 0.5;
    this.add(bg);

    _txt = new FlxText(0, 0, FlxG.width);
    _txt.alignment = "center";
    this.add(_txt);
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var txt = "X: Shot";
    if(_cursor.enable) {
      var cost = Cost.infantry;
      txt += " / C: Buy Tower($" + cost + ")";
    }

    _txt.text = txt;
  }
}
