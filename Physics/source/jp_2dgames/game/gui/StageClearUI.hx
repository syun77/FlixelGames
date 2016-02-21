package jp_2dgames.game.gui;
import jp_2dgames.game.state.EndingState;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.global.Global;
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

    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, "Completed!");
    txt.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
    this.add(txt);

    // 次のレベルに進むボタン
    var btn = new FlxButton(0, FlxG.height*0.6, "Next", function() {
      if(Global.addLevel()) {
        // ゲームクリア
        FlxG.switchState(new EndingState());
      }
      else {
        // 次のステージへ
        FlxG.switchState(new PlayState());
      }
    });
    btn.x = FlxG.width/2 - btn.width/2;
    this.add(btn);

    scrollFactor.set();
  }
}
