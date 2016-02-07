package jp_2dgames.game.gui;
import flixel.text.FlxText;
import jp_2dgames.lib.StatusBar;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  var _hpBar:StatusBar;
  var _txtScore:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _hpBar = new StatusBar(4, 4);
    this.add(_hpBar);

    _txtScore = new FlxText(128, 0);
    this.add(_txtScore);


    scrollFactor.set();
  }

  public override function update():Void {
    super.update();

    // HP更新
    _hpBar.setPercent(Global.getLife());
    // スコア更新
    _txtScore.text = 'SCORE: ${Global.getScore()}';
  }
}
