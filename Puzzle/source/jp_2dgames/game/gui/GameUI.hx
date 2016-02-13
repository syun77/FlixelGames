package jp_2dgames.game.gui;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import jp_2dgames.lib.StatusBar;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  static inline var TIMER_BLINK:Int = 30;

  var _shotBar:StatusBar;
  var _txtTime:FlxText;
  var _elapsed:Float;
  var _bStop:Bool = false;
  var _tBlink:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _shotBar = new StatusBar(4, FlxG.height-8, Std.int(FlxG.width-8), 4);
    this.add(_shotBar);

    _txtTime = new FlxText(FlxG.width*0.4, 40);
    _txtTime.setBorderStyle(FlxText.BORDER_OUTLINE);
    this.add(_txtTime);

    _elapsed = 0;
  }

  public override function update():Void {
    super.update();

    if(_bStop) {
      if(_tBlink > 0) {
        _txtTime.visible = (_tBlink%8 < 4);
        _tBlink--;
      }
      return;
    }

    _elapsed += FlxG.elapsed;

    // 経過時間更新
    var time = Std.int(_elapsed * 1000) / 1000;
    _txtTime.text = '${time}';

    // ショットゲージ更新
    _shotBar.setPercent(Global.getShot());
  }

  public function stop(bBlink:Bool):Void {
    _bStop = true;
    if(bBlink) {
      _tBlink = TIMER_BLINK;
    }
  }
}
