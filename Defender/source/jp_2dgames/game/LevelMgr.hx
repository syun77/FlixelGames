package jp_2dgames.game;

import jp_2dgames.game.global.Global;
import jp_2dgames.game.token.Enemy;
import flixel.group.FlxGroup;

/**
 * 敵生成管理
 **/
class LevelMgr extends FlxGroup {

  // 敵の出現間隔
  var _interval:Float;
  var _tInterval:Float;

  // 敵の出現数
  var _left:Int;
  public var left(get, never):Int;

  // 敵の移動速度
  var _speed:Float;

  // 敵のHP
  var _hp:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    active = false;
  }

  /**
   * Wave開始
   **/
  public function start(wave:Int):Void {

    // 出現間隔
    _interval = 2 - 0.05 * wave;
    if(_tInterval < 1) {
      _tInterval = 1;
    }
    _tInterval = _interval;

    // 敵の出現数
    _left = 5 + Std.int(wave / 3);
    _speed = 10 + 20 * wave;
    _hp = 1 + Std.int(wave / 3);

    active = true;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tInterval -= elapsed;
    if(_tInterval <= 0) {
      // 敵出現
      _spawnEnemy();
    }
  }

  /**
   * 敵の出現
   **/
  function _spawnEnemy():Void {

    if(_left < 1) {
      // 出現できない
      return;
    }

    // 敵の出現
    var level = Global.level;
    var type = EnemyType.Bat;
    var spd  = _speed;
    var hp   = _hp;
    if(level > 1) {
      if(_left%3 == 0) {
        type = EnemyType.Goast;
      }
      if(level > 5) {
        if(_left%7 == 0) {
          type = EnemyType.Snake;
          spd *= 1.5;
          hp = Std.int(hp * 1.5);
        }
      }
    }
    Enemy.add(type, _speed, hp);

    _left--;
    // インターバルを再設定
    _tInterval += _interval;

    if(_left < 1) {
      active = false;
    }
  }


  // -----------------------------------------------
  // ■アクセサ
  function get_left() {
    return _left;
  }
}
