package jp_2dgames.game.token;

import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 背景
 **/
class Bg extends FlxSprite {

  static inline var TIMER_DANGER:Int = 16;

  var _player:Player;
  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    super();
    loadGraphic(AssetPaths.IMAGE_BG);

    _player = player;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_player.isDanger()) {
      // ピンチ状態
      if(_timer < TIMER_DANGER) {
        _timer++;
      }
    }
    else {
      if(_timer > 0) {
        _timer--;
      }
    }

    // ピンチ状態のときは背景を赤くする
    color = FlxColor.interpolate(FlxColor.WHITE, FlxColor.RED, _timer / (TIMER_DANGER*2));
  }
}
