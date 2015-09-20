package jp_2dgames.game;
import flixel.FlxG;
import flixel.FlxState;

/**
 * タイトル画面
 **/
class TitleState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(FlxG.keys.justPressed.ENTER) {
      FlxG.switchState(new PlayState());
    }
  }
}
