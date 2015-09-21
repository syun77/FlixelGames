package jp_2dgames.game.state;

import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム初期化
 **/
class PlayInitState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // グローバルデータ初期化
    Global.init();
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

    FlxG.switchState(new PlayState());
  }
}
