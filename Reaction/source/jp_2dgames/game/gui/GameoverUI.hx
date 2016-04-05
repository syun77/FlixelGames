package jp_2dgames.game.gui;
import jp_2dgames.game.gui.MyButton;
import jp_2dgames.game.state.PlayInitState;
import jp_2dgames.game.global.Global;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームオーバーUI
 **/
class GameoverUI extends FlxSpriteGroup {

  static inline var FONT_SIZE:Int = 16*2;

  public function new(bBtn:Bool=false) {
    super();

    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, "GAME OVER");
    txt.setFormat(null, FONT_SIZE, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    this.add(txt);
    var score = new FlxText(0, FlxG.height*0.5, FlxG.width, 'FINAL SCORE: ${Global.score}');
    score.setFormat(null, FONT_SIZE, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE);
    this.add(score);

    if(bBtn) {
      // やり直しボタン
      var btn = new MyButton(FlxG.width/2, FlxG.height*0.7, "Restart", function() {
        FlxG.switchState(new PlayInitState());
      });
      btn.x -= btn.width/2;
      this.add(btn);
    }
    else {
      // やり直しテキスト
      var txt2 = new FlxText(0, FlxG.height*0.7, FlxG.width, "X to Restart", Std.int(FONT_SIZE/2));
      txt2.alignment = "center";
      this.add(txt2);
    }

    scrollFactor.set();
  }
}
