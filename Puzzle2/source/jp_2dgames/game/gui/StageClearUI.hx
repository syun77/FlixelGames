package jp_2dgames.game.gui;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.state.EndingState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ステージクリアUI
 **/
class StageClearUI extends FlxSpriteGroup {
  public function new() {
    super();

    var txt = new FlxText(0, FlxG.height/2, FlxG.width, "Completed!");
    txt.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
    this.add(txt);

    // 次のレベルに進むテキスト
    var txt2 = new FlxText(0, FlxG.height*0.6, FlxG.width, "X to restart");
    txt2.alignment = "center";
    this.add(txt2);

    scrollFactor.set();
  }
}
