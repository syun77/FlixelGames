package jp_2dgames.game.gui;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームオーバーUI
 **/
class GameoverUI extends FlxSpriteGroup {
  public function new() {
    super();

    var txt = new FlxText(0, FlxG.height/2, FlxG.width, "GAME OVER");
    txt.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
    this.add(txt);
    // やり直しテキスト
    var txt2 = new FlxText(0, FlxG.height*0.6, FlxG.width, "X to restart");
    txt2.alignment = "center";
    this.add(txt2);
  }
}
