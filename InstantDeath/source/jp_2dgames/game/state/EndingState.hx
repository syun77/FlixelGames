package jp_2dgames.game.state;
import jp_2dgames.game.gui.MyButton;
import jp_2dgames.lib.MyColor;
import flixel.ui.FlxButton;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState {
  override public function create():Void
  {
    var fontsize_scale = 2;
    super.create();
    var txt = new FlxText(0, 32, FlxG.width, "Congratulation!", 24*fontsize_scale);
    txt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 2);
    txt.alignment = "center";
    this.add(txt);
    var msg = new FlxText(0, 64, FlxG.width, "completed all of the levels.", 8*fontsize_scale);
    msg.alignment = "center";
    this.add(msg);

    // 下にずらす
    msg.y += 128;

    /*
    // スコア
    var score = new FlxText(0, 128, FlxG.width, 'FINAL SCORE: ${Global.getScore()}', 16);
    score.alignment = "center";
    this.add(score);
    */
    // タイトルに戻るボタン
    var btn = new MyButton(0, FlxG.height*0.8, "Back to TITLE", function() {
      FlxG.switchState(new TitleState());
    });
    btn.x = FlxG.width/2 - btn.width/2;
    this.add(btn);
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
