package jp_2dgames.game;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.token.Boss;
import flixel.FlxBasic;

/**
 * レベル管理
 **/
class LevelMgr extends FlxBasic {

  var _boss:Boss;

  /**
   * コンストラクタ
   **/
  public function new(boss:Boss) {
    super();
    _boss = boss;
    _boss.kill();
  }

  public function start():Void {
    _boss.revive();
    var level = Global.level;
    _boss.init2(101);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_boss.exists == false) {
      start();
    }
  }
}
