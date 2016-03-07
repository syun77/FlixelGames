package jp_2dgames.game;

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

  // 敵の移動速度
  var _speed:Float;

  // 敵のHP
  var _hp:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _interval = 1;
    _tInterval = _interval;

    // TODO:
    _left = 100;
    _speed = 10;
    _hp = 1;
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

    if(_left <= 0) {
      // 出現できない
      return;
    }

    // 敵の出現
    Enemy.add(EnemyType.Snake, _speed, _hp);

    _left--;
    // インターバルを再設定
    _tInterval += _interval;
  }
}
