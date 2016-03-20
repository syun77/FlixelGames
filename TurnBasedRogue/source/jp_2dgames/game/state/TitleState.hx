package jp_2dgames.game.state;
import flixel.FlxSprite;
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
    bg.makeGraphic(FlxG.width, 32, FlxColor.GRAY);
    this.add(bg);
    var txt = new FlxText(0, FlxG.height*0.2, FlxG.width, "SUPER SIMPLE RL");
    txt.setFormat(null, 24, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, 0xFF3c3c3c);
    this.add(txt);
    new FlxTimer().start(3, function(timer:FlxTimer) {
      var w = FlxG.random.float(0.005, 0.01);
      var d = FlxG.random.float(0.1, 0.25);
      FlxG.camera.shake(w, d);
      var t = FlxG.random.float(0.5, 5);
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

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
