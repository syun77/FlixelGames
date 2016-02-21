package jp_2dgames.game.gui;
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

  var _txtLevel:FlxText;
  var _txtLife:FlxText;


  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // レベル
    var px = 4;
    var py = 4;
    _txtLevel = new FlxText(px, py);
    this.add(_txtLevel);
    py += 12;

    // ライフ
    _txtLife = new FlxText(px, py);
    this.add(_txtLife);

    scrollFactor.set();
  }

  public override function update():Void {
    super.update();

    // レベル更新
    var lv = Global.getLevel();
    _txtLevel.text = 'LEVEL: ${Global.getLevel()}';

    // ライフ
    _txtLife.text = 'LIFE: ${Global.getLife()}';

  }
}
