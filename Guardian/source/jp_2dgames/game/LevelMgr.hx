package jp_2dgames.game;

import jp_2dgames.lib.MyMath;
import jp_2dgames.game.token.Enemy;
import flixel.FlxG;
import flixel.FlxBasic;

/**
 * レベル管理
 **/
class LevelMgr extends FlxBasic {

  static inline var INTERVAL_FIRST:Int = 60;
  static inline var INTERVAL_LAST:Int = 30;
  static inline var SPEED_FIRST:Float = 5.0;
  static inline var SPEED_LAST:Float = 100.0;

  var _timer:Int = 0;
  var _tInterval:Int = INTERVAL_FIRST;
  var _speed:Float = SPEED_FIRST;

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

    _tInterval = Std.int(INTERVAL_FIRST - (INTERVAL_FIRST-INTERVAL_LAST)*(MyMath.calcRank3MIN(_timer)-1));
    if(_tInterval < INTERVAL_LAST) {
      _tInterval = INTERVAL_LAST;
    }
    _speed = SPEED_FIRST + (SPEED_LAST - SPEED_FIRST)*(MyMath.calcRank3MIN(_timer)-1);

    _timer++;
    if(_timer%_tInterval == 0) {
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
    var attr = EnemyAttr.Normal;
    attr = EnemyAttr.Bomb;
    var spd = _speed;
    if(FlxG.random.bool(10)) {
      // 10%で高速爆弾出現
      spd *= 2;
    }

    Enemy.add(type, attr, px, py, spd);
  }
}
