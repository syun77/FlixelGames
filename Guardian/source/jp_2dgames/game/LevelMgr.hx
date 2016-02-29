package jp_2dgames.game;

import jp_2dgames.game.token.Enemy;
import flixel.FlxG;
import flixel.FlxBasic;

/**
 * レベル管理
 **/
class LevelMgr extends FlxBasic {

  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _timer++;
    if(_timer%30 == 0) {
      _addEnemy();
    }
  }

  /**
   * 敵の生成
   **/
  function _addEnemy():Void {
    var px = FlxG.random.float(-8, FlxG.width);
    var py = FlxG.random.float(-8, FlxG.height);
    switch(FlxG.random.int(0, 3)) {
      case 0: px = -8;
      case 1: px = FlxG.width;
      case 2: py = -8;
      case 3: py = FlxG.height;
    }
    var type = Enemy.randomType();

    Enemy.add(type, px, py, 10);
  }
}
