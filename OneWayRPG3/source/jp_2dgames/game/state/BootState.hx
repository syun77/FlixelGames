package jp_2dgames.game.state;
import jp_2dgames.game.dat.MyDBUtil;
import jp_2dgames.lib.MyTransition;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 起動画面
 **/
class BootState extends FlxState {
  override public function create():Void {
    super.create();

    FlxG.debugger.toggleKeys = ["ALT"];

    MyDBUtil.load();

    // トランジション用オブジェクト生成
    MyTransition.create();
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    #if flash
    FlxG.switchState(new TitleState());
    #else
    FlxG.switchState(new PlayInitState());
//    FlxG.switchState(BtlGroupUtil TitleState());
//    FlxG.switchState(BtlGroupUtil EndingState());
    #end
  }
}
