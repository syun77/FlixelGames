package jp_2dgames.game;

import jp_2dgames.game.global.Global;
import jp_2dgames.lib.MyMath;
import jp_2dgames.game.token.Enemy;
import flixel.FlxG;
import flixel.math.FlxPoint;
import jp_2dgames.game.token.Player;
import flixel.FlxBasic;

/**
 * 敵出現管理
 **/
class LevelMgr extends FlxBasic {

  var _player:Player;
  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    super();
    _player = player;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(Enemy.parent.countLiving() > 0) {
      return;
    }
    _timer++;
    if(_timer%120 == 1) {
      _appearEnemy();
    }

    if(_timer%300 == 0) {
      // レベルアップ
      Global.addLevel();
    }
  }

  /**
   * 敵出現
   **/
  function _appearEnemy():Void {
    var pt = _appearPoint();
    var dx = FlxG.width/2 - pt.x;
    var dy = FlxG.height/2 - pt.y;
    var deg = MyMath.atan2Ex(-dy, dx);

    var eid = _choice(Global.level);
    Enemy.add(eid, pt.x, pt.y, deg, 600);
    pt.put();
  }

  function _choice(level:Int):Int {
    if(level < 3) {
      return 1;
    }
    var func = function():Array<Int> {
      if(level%9 == 0) {
        return [1];
      }
      if(level%13 == 0) {
        return [2];
      }
      return [1, 2];
    }
    var arr = func();

    var idx = FlxG.random.int(0, arr.length-1);
    return arr[idx];
  }

  /**
   * 出現座標を取得する
   **/
  function _appearPoint():FlxPoint {
    var MARGIN:Int = 64;
    var pt = FlxPoint.get();
    if(FlxG.random.bool()) {
      // X座標をランダム
      pt.x = FlxG.random.float(0, FlxG.width);
      if(_player.y < FlxG.height/2) {
        // 下から出現
        pt.y = FlxG.height + MARGIN;
      }
      else {
        // 上から出現
        pt.y = -MARGIN;
      }
    }
    else {
      // Y座標をランダム
      pt.y = FlxG.random.float(0, FlxG.height);
      if(_player.x < FlxG.width/2) {
        // 右から出現
        pt.x = FlxG.width + MARGIN;
      }
      else {
        // 左から出現
        pt.x = -MARGIN;
      }
    }

    return pt;
  }
}
