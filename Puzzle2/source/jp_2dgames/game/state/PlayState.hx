package jp_2dgames.game.state;

import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

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

    #if debug
    _updateDebug();
    #end
  }

  function _updateDebug():Void {

    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      throw "Terminate.";
    }
    if(FlxG.keys.justPressed.L) {
      // リスタート
      FlxG.resetState();
    }
  }
}
