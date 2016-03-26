package jp_2dgames.game.state;
import flixel.util.FlxColor;
import jp_2dgames.lib.Input;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

/**
 * 起動画面
 **/
class PlayStartState extends FlxState {

  var _player:FlxSprite;
  var _timer:Float = 0.0;

  override public function create():Void {
    super.create();

    bgColor = FlxColor.BLACK;

    #if debug
    FlxG.switchState(new PlayState());
    return;
    #end

    {
      var lvText = new FlxText(0, FlxG.height*0.3, FlxG.width);
      lvText.alignment = "center";
      lvText.text = 'LEVEL ${Global.level} / ${Global.MAX_LEVEL-1}';
      this.add(lvText);
    }

    _player = new FlxSprite(FlxG.width*0.4, FlxG.height*0.5);
    _player.loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _player.animation.add("play", [0, 0, 1, 0, 0], 3);
    _player.animation.play("play");
    this.add(_player);

    var txt = new FlxText(FlxG.width*0.5, FlxG.height*0.5);
    txt.text = 'x ${Global.life}';
    this.add(txt);

  }

  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(Input.press.B) {
      _timer += 3;
    }
    _timer += elapsed;
    if(_timer > 3) {
      FlxG.switchState(new PlayState());
    }
  }
}
