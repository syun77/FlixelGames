package jp_2dgames.game.state;

import jp_2dgames.game.token.Block;
import jp_2dgames.game.util.Field;
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

    Field.create();
    Block.createParent(this);

    Field.createBlock(this);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    Field.destroy();
    Block.destroyParent();

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