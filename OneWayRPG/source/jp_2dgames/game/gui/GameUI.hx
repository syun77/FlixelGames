package jp_2dgames.game.gui;

import flixel.FlxSprite;
import flixel.util.FlxColor;
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
  var _txtHp:FlxText;
  var _orbs:Array<FlxSprite>;

  var _tAnim:Int = 0;

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
//    this.add(_txtLevel);
    _txtLevel.y -= FONT_SIZE-4;

    // オーブ
    _orbs = new Array<FlxSprite>();
    for(i in 0...Global.MAX_ORB) {
      var orb = new FlxSprite(px + i * 24, py);
      orb.loadGraphic(AssetPaths.IMAGE_ITEM, true);
      for(i in 0...Global.MAX_ORB+1) {
        var idx = i + 8;
        orb.animation.add('${i}', [idx], 1);
      }
      orb.animation.play('4');
      var sc = 0.75;
      orb.scale.set(sc, sc);
      this.add(orb);
      _orbs.push(orb);
    }

    // HP
    px += FlxG.width * 0.3;
    py += 10;
//    _barHp = BtlGroupUtil StatusBar(px, py, 256, 16, true);
    _barHp = new FlxBar(px, py, null, 256, 16, null, "", 0, 100, true);
    this.add(_barHp);

    // HPテキスト
    _txtHp = new FlxText(px+100*2.6, py-2, 0, "", FONT_SIZE);
    this.add(_txtHp);

    scrollFactor.set();
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

    _txtScore.text = 'SCORE: ${Global.score}';
    _txtLevel.text = 'LEVEL: ${Global.level}';
//    _barHp.setPercent(Global.life);
    _barHp.percent = Global.life;
    var hp = Std.int(Global.life);
    var hpmax = Std.int(Global.MAX_LIFE);
    _txtHp.text = '${hp}/${hpmax}';
    _txtHp.color = FlxColor.WHITE;
    if(hp < 40 && _tAnim%32 < 16) {
      // 危険
      _txtHp.color = FlxColor.RED;
    }

    // オーブ
    for(i in 0...Global.MAX_ORB) {
      var orb:FlxSprite = _orbs[i];
      if(Global.hasOrb(i)) {
        orb.animation.play('${i}');
      }
      else {
        orb.animation.play('4');
      }
    }
  }
}
