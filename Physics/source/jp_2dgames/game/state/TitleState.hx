package jp_2dgames.game.state;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxState;

/**
 * タイトル画面
 **/
class TitleState extends FlxState {
  override public function create():Void
  {
    super.create();

    var bg = new FlxSprite(0, FlxG.height*0.2);
    bg.makeGraphic(FlxG.width, 32, FlxColor.CHARCOAL);
    this.add(bg);
    var txt = new FlxText(0, FlxG.height*0.2, FlxG.width, "HELL BALL");
    txt.setFormat(null, 24, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE, FlxColor.KHAKI);
    this.add(txt);
    new FlxTimer(3, function(timer:FlxTimer) {
      var w = FlxRandom.floatRanged(0.005, 0.01);
      var d = FlxRandom.floatRanged(0.1, 0.25);
      FlxG.camera.shake(w, d);
      var t = FlxRandom.floatRanged(0.5, 5);
      timer.reset(t);
    });

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
