package jp_2dgames.game.state;
import flixel.FlxG;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState {
  override public function create():Void
  {
    super.create();
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update():Void
  {
    super.update();

    FlxG.switchState(new TitleState());
  }
}
