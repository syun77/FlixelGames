package jp_2dgames.game.state;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import jp_2dgames.game.token.Block;
import jp_2dgames.game.util.Field;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム画面
 **/
class PlayState extends FlxState {

  var _floor:FlxSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    _floor = new FlxSprite(0, FlxG.height-16);
    _floor.immovable = true;
    _floor.makeGraphic(FlxG.width, 128, FlxColor.WHITE);
    this.add(_floor);
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

    FlxG.debugger.drawDebug = true;
    FlxG.collide(_floor, Block.parent);
    FlxG.overlap(Block.parent, Block.parent, _BlockVsBlock);

    if(FlxG.mouse.justPressed) {
      var px = FlxG.mouse.x;
      var py = FlxG.mouse.y;
      var hit = new FlxSprite(px, py, AssetPaths.IMAGE_BLOCK);
      FlxG.overlap(hit, Block.parent, function(hit:FlxSprite, block:Block) {
        block.vanish();
      });
    }

    #if neko
    _updateDebug();
    #end
  }

  function _BlockVsBlock(b1:Block, b2:Block):Void {
    if(b1.y < b2.y) {
      b1.snapGrip();
    }
    else {
      b2.snapGrip();
    }
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