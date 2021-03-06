package jp_2dgames.game.state;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 起動画面
 **/
class BootState extends FlxState {
  override public function create():Void
  {
    super.create();

    FlxG.debugger.toggleKeys = ["ALT"];
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update():Void
  {
    super.update();

//    FlxG.switchState(new PlayInitState());
    FlxG.switchState(new TitleState());
  }
}
