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

    var txt = new FlxText(0, FlxG.height/2, FlxG.width, "GAME OVER");
    txt.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
    this.add(txt);
    // やり直しボタンを配置
    var px = FlxG.width/2;
    var py = FlxG.height * 0.7;
    var btn = new FlxButton(px, py, "BACK TO TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x -= btn.width/2;
    this.add(btn);

    scrollFactor.set();
  }
}
