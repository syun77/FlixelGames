package jp_2dgames.game;

import flixel.FlxG;
import flixel.FlxState;
class PlayState extends FlxState {

  var _player:Player;

  override public function create():Void {
    super.create();

    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);
  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update():Void {
    super.update();
  }
}