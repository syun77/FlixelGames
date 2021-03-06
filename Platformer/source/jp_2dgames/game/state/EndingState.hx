package jp_2dgames.game.state;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState {
  override public function create():Void
  {
    super.create();

    var txt = new FlxText(0, 64, FlxG.width, "Congratulation!", 24);
    txt.alignment = "center";
    this.add(txt);
    var msg = new FlxText(0, 128, FlxG.width, "complete all of the levels.");
    msg.alignment = "center";
    this.add(msg);

    var player = new FlxSprite(0, FlxG.height - 64);
    player.loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    player.animation.add("play", [2, 3], 8);
    player.animation.play("play");
    var func = function(x:Float) return x;
    FlxTween.tween(player, {x:FlxG.width+32}, 6, {ease:func, complete:function(tween:FlxTween) {
      FlxG.switchState(new TitleState());
    }});
    this.add(player);
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
