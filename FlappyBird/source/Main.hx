package;

import jp_2dgames.game.state.BootState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(400, 240, BootState, 1, 60, 60, true));
	}
}