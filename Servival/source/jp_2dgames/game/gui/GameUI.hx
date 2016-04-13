package jp_2dgames.game.gui;

import flixel.ui.FlxBar;
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

  static inline var FONT_SIZE:Int = 8 * 2;

  // ---------------------------------------------------
  // ■フィールド
  var _txtLevel:FlxText;
  var _txtScore:FlxText;
  var _barHp:FlxBar;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(4, 2);

    var px:Float = 0;
    var py:Float = 0;

    // スコア
    _txtScore = new FlxText(px, py, 0, "", FONT_SIZE);
//    this.add(_txtScore);

    // レベル
    _txtLevel = new FlxText(px, py+FONT_SIZE+4, 0, "", FONT_SIZE);
    this.add(_txtLevel);
    _txtLevel.y -= FONT_SIZE-4;

    // HP
    px += FlxG.width * 0.4;
    py += 2;
//    _barHp = new StatusBar(px, py, 256, 16, true);
    _barHp = new FlxBar(px, py, null, 256, 16, null, "", 0, 100, true);
    this.add(_barHp);


    scrollFactor.set();
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    _txtScore.text = 'SCORE: ${Global.score}';
    _txtLevel.text = 'LEVEL: ${Global.level}';
//    _barHp.setPercent(Global.life);
    _barHp.percent = Global.life;
  }
}
