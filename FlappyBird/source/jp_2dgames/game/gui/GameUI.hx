package jp_2dgames.game.gui;

import jp_2dgames.lib.StatusBar;
import flixel.math.FlxPoint;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  static inline var FONT_SIZE:Int = 8;

  // ---------------------------------------------------
  // ■フィールド
  var _txtScore:FlxText;
  var _barHorming:StatusBar;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(4, 2);

    var px:Float = 0;
    var py:Float = 0;

    // スコア
    _txtScore = new FlxText(px, py, 0, "", FONT_SIZE);
    this.add(_txtScore);

    // ホーミングゲージ
    px += FlxG.width * 0.25;
    py += 2;
    _barHorming = new StatusBar(px, py, 128, 8, true);
    this.add(_barHorming);

    scrollFactor.set();
  }

  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    _txtScore.text = 'SCORE: ${Global.score}';
    _barHorming.setPercent(Global.shot);
  }
}
