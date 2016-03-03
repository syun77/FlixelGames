package jp_2dgames.game.gui;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flash.display.SpreadMethod;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  var _txtScore:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    var px:Float = 4;
    var py:Float = 4;

    // スコア
    _txtScore = new FlxText(px, py, 0, "", 8);
    _txtScore.setBorderStyle(FlxTextBorderStyle.OUTLINE);
    this.add(_txtScore);

    scrollFactor.set();
  }

  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    // スコア
    _txtScore.text = 'SCORE: ${Global.getScore()}';

  }
}
