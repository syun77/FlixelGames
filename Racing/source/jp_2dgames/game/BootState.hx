package jp_2dgames.game;

import jp_2dgames.lib.Snd;
import flixel.FlxG;
import flixel.FlxState;

/**
 * タイトル画面
 **/
class BootState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    Snd.cache();
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

    FlxG.switchState(new TitleState());
//    FlxG.switchState(new PlayState());
  }
}
