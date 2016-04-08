package jp_2dgames.game.state;
import jp_2dgames.game.global.Global;
import flixel.FlxG;
import flixel.FlxState;

/**
 * ゲーム開始画面
 **/
class PlayInitState extends FlxState {
  override public function create():Void
  {
    super.create();

    Global.initGame();
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    FlxG.switchState(new PlayState());
  }
}
