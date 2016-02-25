package jp_2dgames.game.gui;
import jp_2dgames.game.state.TitleState;
import flixel.ui.FlxButton;
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

    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, "GAME OVER");
    txt.setFormat(null, 32, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
    this.add(txt);
    // やり直しテキスト
    var txt2 = new FlxText(0, FlxG.height*0.6, FlxG.width, "X to Restart", 16);
    txt2.alignment = "center";
    this.add(txt2);

    scrollFactor.set();
  }
}
