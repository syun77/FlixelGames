package jp_2dgames.game.state;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxState;

/**
 * タイトル画面
 **/
class TitleState extends FlxState {
  override public function create():Void
  {
    super.create();

    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, "BASEMENT SHOOTER");
    txt.setFormat(null, 24, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE, FlxColor.KHAKI);
    this.add(txt);

    var btn = new FlxButton(FlxG.width/2, FlxG.height*0.7, "CLICK HERE", function() {
      FlxG.switchState(new PlayInitState());
    });
    btn.x -= btn.width/2;
    this.add(btn);

    var txtCopy = new FlxText(0, FlxG.height-32, FlxG.width, "(C) 2016 2dgames.jp");
    txtCopy.alignment = "center";
    this.add(txtCopy);
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update():Void
  {
    super.update();
  }
}
