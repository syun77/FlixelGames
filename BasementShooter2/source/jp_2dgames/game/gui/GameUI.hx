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

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _bossBar = new StatusBar(FlxG.width/4, 4, Std.int(FlxG.width*0.5), 8);
    _bossBar.createFilledBar(0xff510000, 0xffF40000);
    this.add(_bossBar);

    _hpBar = new StatusBar(FlxG.width/4, FlxG.height-24, Std.int(FlxG.width*0.5), 8, true);
    this.add(_hpBar);
    _txtHp = new FlxText(FlxG.width/4, FlxG.height-28, null, 16);
    _txtHp.setBorderStyle(FlxText.BORDER_OUTLINE, 2, FlxColor.GREEN);
    this.add(_txtHp);

    _txtScore = new FlxText(8, FlxG.height-28, null, 16);
    _txtHp.setBorderStyle(FlxText.BORDER_OUTLINE, 2);
    this.add(_txtScore);


    scrollFactor.set();
  }

  public override function update():Void {
    super.update();

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
    if(Global.getLifeRatio() < 40) {
      _txtHp.color = FlxColor.CRIMSON;
    }
    else {
      _txtHp.color = FlxColor.WHITE;
    }
    // スコア更新
    _txtScore.text = 'SCORE: ${Global.getScore()}';
  }
}
