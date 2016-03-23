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

  static inline var FONT_SIZE = 16;

  public function new(bUseButton:Bool) {
    super();

    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, "Completed!");
    txt.setFormat(null, FONT_SIZE, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE);
    this.add(txt);

    if(bUseButton) {
      // 次のレベルに進むボタン
      var btn = new FlxButton(0, FlxG.height*0.6, "Next", nextLevel);
      btn.x = FlxG.width/2 - btn.width/2;
      this.add(btn);
    }
    else {
      // 次のレベルに進むテキスト
      var txt2 = new FlxText(0, FlxG.height*0.6, FlxG.width, "X to Next", FONT_SIZE);
      txt2.alignment = "center";
      this.add(txt2);
    }

    scrollFactor.set();
  }

  public static function nextLevel():Void {
    if(Global.addLevel()) {
      // ゲームクリア
      FlxG.switchState(new EndingState());
    }
    else {
      // 次のステージへ
      FlxG.switchState(new PlayState());
    }
  }
}
