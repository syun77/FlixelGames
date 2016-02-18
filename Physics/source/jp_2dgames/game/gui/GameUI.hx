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

  var _btnRetry:FlxButton;
  var _txtLevel:FlxText;
  var _txtKey:FlxText;


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
    var px = 4;
    var py = 4;
    _txtLevel = new FlxText(px, py);
    this.add(_txtLevel);
    py += 12;

    // カギの数
    var sprKey = new FlxSprite(px-4, py);
    sprKey.loadGraphic(AssetPaths.IMAGE_KEY, true);
    sprKey.animation.add("play", [0, 1], 2);
    sprKey.animation.play("play");
    var sc = 0.5;
    sprKey.scale.set(sc, sc);
    this.add(sprKey);
    _txtKey = new FlxText(px+8, py);
    this.add(_txtKey);

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

    // カギの所持数
    _txtKey.text = 'x ${Global.getKey()}';

  }
}
