package jp_2dgames.game;

import jp_2dgames.lib.Snd;
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

    Snd.playMusic('1');
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _updateZaco();
    _updateBoss();

    _timer++;
    if(_timer%300 == 0) {
      // レベルアップ
      Global.addLevel();
      if(Global.level%5 == 0) {
        Snd.playMusic('${1 + (Std.int(Global.level/5)%3)}');
      }
    }
  }

  function _updateZaco():Void {
    var level = Global.level;
    var zaco = Enemy.countZaco();
    var max = _getMaxZaco(level);
    var min = _getMinZaco(level);
    if(zaco >= max) {
      // 最大数を超えないようにする
      return;
    }
    if(zaco < min) {
      // 最大数を下回っているので必ず出現
      _appearEnemy();
    }
    else if(_timer%120 == 1) {
      _appearEnemy();
    }
  }

  function _updateBoss():Void {
    var level = Global.level;
    var boss = Enemy.countBoss();
    var max = _getMaxBoss(level);
    if(boss >= max) {
      // 最大数を超えないようにする
      return;
    }

    if(_timer%180 == 0) {
      _appearBoss();
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
      if(level%7 == 0) {
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
   * ボス出現
   **/
  function _appearBoss():Void {
    var pt = _appearPoint();
    var dx = FlxG.width/2 - pt.x;
    var dy = FlxG.height/2 - pt.y;
    var deg = MyMath.atan2Ex(-dy, dx);

    var eid = _choiceBoss(Global.level);
    Enemy.add(eid, pt.x, pt.y, deg, 600);
    pt.put();
  }

  function _choiceBoss(level:Int):Int {
    if(level < 10) {
      return 10;
    }
    var func = function():Array<Int> {
      if(level%5 == 0) {
        return [10];
      }
      if(level%7 == 0) {
        return [11];
      }
      return [10, 11];
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

  function _getMinZaco(level:Int):Int {
    if(level < 3) {
      return 2;
    }
    if(level < 6) {
      return 3;
    }
    if(level < 12) {
      return 4;
    }
    return 1 + Std.int(level/4);
  }
  function _getMaxZaco(level:Int):Int {
    if(level < 3) {
      return 5;
    }
    if(level < 12) {
      return 6;
    }
    return 4 + Std.int(level/4);
  }
  function _getMaxBoss(level:Int):Int {
    if(level < 5) {
      return 0;
    }
    if(level < 10) {
      return 1;
    }
    if(level < 15) {
      return 2;
    }
    if(level < 20) {
      return 3;
    }
    return Std.int(level/4);
  }
}
