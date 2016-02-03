package jp_2dgames.game.gui;
import jp_2dgames.lib.StatusBar;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  var _hpBar:StatusBar;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _hpBar = new StatusBar(4, 4);
    this.add(_hpBar);

    scrollFactor.set();
  }

  public override function update():Void {
    super.update();

    _hpBar.setPercent(Global.getLife());
  }
}
