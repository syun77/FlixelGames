package jp_2dgames.game.gui;
import flixel.ui.FlxButton;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import jp_2dgames.lib.StatusBar;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  var _btnRetry:FlxButton;
  var _txtLevel:FlxText;


  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // やり直しボタン
    _btnRetry = new FlxButton(4, 0, "RETRY", function() {
      FlxG.resetState();
    });
    _btnRetry.y = FlxG.height - _btnRetry.height - 4;
    this.add(_btnRetry);

    // レベル
    _txtLevel = new FlxText(4, 4);
    this.add(_txtLevel);

    scrollFactor.set();
  }

  public function hideRetry():Void {
    _btnRetry.visible = false;
  }

  public override function update():Void {
    super.update();

    // レベル更新
    var lv = Global.getLevel();
    _txtLevel.text = 'LEVEL: ${Global.getLevel()}';

  }
}
