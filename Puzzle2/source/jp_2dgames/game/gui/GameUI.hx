package jp_2dgames.game.gui;
import jp_2dgames.game.token.enemy.EnemyMgr;
import flixel.util.FlxColor;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import jp_2dgames.lib.StatusBar;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  var _hpBar:StatusBar;
  var _txtHp:FlxText;
  var _txtScore:FlxText;

  var _bossBar:StatusBar;
  var _txtLevel:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _bossBar = new StatusBar(FlxG.width/4, 4, Std.int(FlxG.width*0.5), 8);
    _bossBar.createFilledBar(0xff510000, 0xffF40000);
    this.add(_bossBar);

    _txtLevel = new FlxText(8, 4);
    _txtLevel.setBorderStyle(FlxText.BORDER_OUTLINE);
    this.add(_txtLevel);

    _hpBar = new StatusBar(FlxG.width/4, FlxG.height-12, Std.int(FlxG.width*0.5), 8, true);
    this.add(_hpBar);
    _txtHp = new FlxText(FlxG.width/4, FlxG.height-14);
    _txtHp.setBorderStyle(FlxText.BORDER_OUTLINE, 2, FlxColor.GREEN);
    this.add(_txtHp);

    _txtScore = new FlxText(8, FlxG.height-1);
    _txtHp.setBorderStyle(FlxText.BORDER_OUTLINE);
    this.add(_txtScore);


    scrollFactor.set();
  }

  public override function update():Void {
    super.update();

    // レベル更新
    var lv = Global.getLevel();
    if(lv == 0) {
      _txtLevel.text = "";
    }
    else {
      _txtLevel.text = 'LEVEL: ${Global.getLevel()}';
    }

    // ボスHP更新
    {
      var boss = EnemyMgr.bosses.getFirstAlive();
      if(boss != null) {
        var ratio = boss.getHpRatio();
        _bossBar.setPercent(ratio);
        _bossBar.visible = true;
      }
      else {
        _bossBar.visible = false;
      }
    }

    // HP更新
    _hpBar.setPercent(Global.getLife());
    _txtHp.text = '${Global.getLifeRatio()}%';
    if(Global.isLifeDanger()) {
      _txtHp.color = FlxColor.CRIMSON;
    }
    else {
      _txtHp.color = FlxColor.WHITE;
    }
    // スコア更新
    _txtScore.text = 'SCORE: ${Global.getScore()}';
  }
}
