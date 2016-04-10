package jp_2dgames.game.state;
import jp_2dgames.game.token.EnemyInfo;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 起動画面
 **/
class BootState extends FlxState {
  override public function create():Void {
    super.create();

    FlxG.debugger.toggleKeys = ["ALT"];

    EnemyInfo.load();
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    #if flash
    FlxG.switchState(new TitleState());
    #else
//    FlxG.switchState(new PlayInitState());
//    FlxG.switchState(new TitleState());
    FlxG.switchState(new EndingState());
    #end
  }
}
