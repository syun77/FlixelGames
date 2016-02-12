package jp_2dgames.game.state;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import jp_2dgames.lib.Array2D;
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

    var layer = new Array2D(10, 20);
    layer.set(5, 10, 1);
    layer.set(4, 11, 1);

    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = i * 16;
      var y = j * 16;
      switch(v) {
        case 1:
          var spr = new FlxSprite(x, y);
          spr.makeGraphic(16, 16, FlxColor.WHITE);
          this.add(spr);
      }
    });
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
    #if neko
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