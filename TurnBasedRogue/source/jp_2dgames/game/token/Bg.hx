package jp_2dgames.game.token;
import flixel.util.FlxColor;
import jp_2dgames.game.global.Global;
import flixel.FlxSprite;

/**
 * 背景
 **/
class Bg extends FlxSprite {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var life = Global.life;
    color = FlxColor.WHITE;
    switch(life) {
      case 0:
        color = FlxColor.RED;
      case 1:
        color = 0xFFFF3333;
      case 2:
        color = 0xFFFF6666;
      case 3:
        color = 0xFFFF9999;
      case 4:
        color = 0xFFFFCCCC;
    }
  }

}
