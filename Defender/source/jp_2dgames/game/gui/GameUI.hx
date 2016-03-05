package jp_2dgames.game.gui;
import jp_2dgames.lib.StatusBar;
import flixel.text.FlxText.FlxTextBorderStyle;
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
  var _txtHp:FlxText;
  var _hpBar:StatusBar;

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

    // HPゲージ
    _hpBar = new StatusBar(FlxG.width-108, py+2, true);
    this.add(_hpBar);


    // HP
    _txtHp = new FlxText(0, py+10, 0, "", 8);
    _txtHp.x = FlxG.width - 108;
    _txtHp.setBorderStyle(FlxTextBorderStyle.OUTLINE);
    this.add(_txtHp);


    scrollFactor.set();
  }

  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    // スコア
    _txtScore.text = 'SCORE: ${Global.getScore()}';

    // HP
    _txtHp.text = 'HP: ${Global.getLife()}';
    _hpBar.setPercent(100 * Global.getLife() / Global.MAX_LIFE);
  }
}
