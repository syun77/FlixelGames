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

  var _txtLevel:FlxText;
  var _txtLife:FlxText;
  var _txtMessage:FlxText;
  var _bar:FlxBar;
  var _timer:Int = 0;


  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // レベル
    var px:Float = 4;
    var py:Float = 4;
    _txtLevel = new FlxText(px, py);
    _txtLevel.setBorderStyle(FlxText.BORDER_OUTLINE);
    this.add(_txtLevel);
    py += 12;

    // ライフ
    _txtLife = new FlxText(px, py);
    _txtLife.setBorderStyle(FlxText.BORDER_OUTLINE);
    this.add(_txtLife);

    px = FlxG.width * 0.3;
    py = 4;
    // メッセージ
    _txtMessage = new FlxText(px, py);
    _txtMessage.setBorderStyle(FlxText.BORDER_OUTLINE);
    this.add(_txtMessage);

    scrollFactor.set();
  }

  public function showMessage(str:String):Void {
    _txtMessage.text = str;
    _txtMessage.visible = true;
  }

  public function hideMessage():Void {
    _txtMessage.visible = false;
  }

  public override function update():Void {
    super.update();

    _timer++;

    // レベル更新
    var lv = Global.getLevel();
    _txtLevel.text = 'LEVEL: ${Global.getLevel()}';

    // ライフ
    _txtLife.text = 'LIFE: ${Global.getLife()}';

    // メッセージ点滅
    if(_txtMessage.visible) {
      if(_timer%16 < 8) {
        _txtMessage.color = FlxColor.YELLOW;
      }
      else {
        _txtMessage.color = FlxColor.WHITE;
      }
    }
  }
}
