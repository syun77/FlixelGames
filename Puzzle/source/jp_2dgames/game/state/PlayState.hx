package jp_2dgames.game.state;

import jp_2dgames.game.particle.Particle;
import flixel.util.FlxRandom;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import jp_2dgames.game.token.Player;
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

  var _floors:FlxGroup;
  var _player:Player;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    _floors = new FlxGroup();
    var floor1 = new FlxSprite(0, 0);
    floor1.immovable = true;
    floor1.makeGraphic(Field.TILE_WIDTH, FlxG.height, FlxColor.WHITE);
    _floors.add(floor1);
    var floor2 = new FlxSprite(FlxG.width-Field.TILE_WIDTH, 0);
    floor2.immovable = true;
    floor2.makeGraphic(Field.TILE_WIDTH, FlxG.height, FlxColor.WHITE);
    _floors.add(floor2);
    var floor3 = new FlxSprite(0, FlxG.height-Field.TILE_HEIGHT);
    floor3.immovable = true;
    floor3.makeGraphic(FlxG.width, 128, FlxColor.WHITE);
    _floors.add(floor3);
    this.add(_floors);

    Field.create();
    Block.createParent(this);

    _player = new Player(32, 32);
    this.add(_player);

    Particle.createParent(this);

    Field.createBlock(this);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    Field.destroy();
    Block.destroyParent();
    Particle.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(FlxRandom.chanceRoll(1)) {
      var i = FlxRandom.intRanged(1, Field.WIDTH-1);
      Block.add(i, 0);
    }

    FlxG.collide(_floors, Block.parent);
    FlxG.collide(Block.parent, Block.parent, _BlockVsBlock);
    FlxG.collide(_player, _floors);

    if(FlxG.mouse.justPressed) {
      _player.x = FlxG.mouse.x;
      _player.y = FlxG.mouse.y;
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