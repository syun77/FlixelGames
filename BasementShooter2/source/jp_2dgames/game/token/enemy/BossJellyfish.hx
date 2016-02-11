package jp_2dgames.game.token.enemy;

import flixel.util.FlxTimer;
import jp_2dgames.game.token.enemy.Enemy;

import flixel.util.FlxRandom;
/**
 * クラゲAI
 **/
class BossJellyfish extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 15;
    _timer += 10 * e.level;
    if(_timer > 180) {
      _timer = 180;
    }
  }

  /**
   * 移動
   **/
  override public function move(e:Enemy):Void {
    if(_timer%240 == 0) {
      var deg = e.getAim();
      var spd = 150;
      switch(e.getDistType()) {
        case Enemy.DIST_NEAR:
          deg -= 180; // 離れる
          e.setVelocity(deg, spd);
        case Enemy.DIST_MID:
          if(FlxRandom.chanceRoll(25)) {
            deg -= 180; // 離れる
          }
          else {
            if(FlxRandom.chanceRoll()) {
              deg += 90;
            }
            else {
              deg -= 90;
            }
          }
          e.setVelocity(deg, spd);
        case Enemy.DIST_FAR:
          // 近づく
          e.setVelocity(deg, spd);
          // 連続で行動
          _timer += 60;
      }
      _timer += FlxRandom.intRanged(0, 60);
    }
    // 速度減衰
    e.decayVelocity(0.97);
  }

  override public function attack(e:Enemy):Void {
    var px = e.xcenter;
    var py = e.ycenter;

    var aim = e.getAim();
    switch(_timer) {
      case 200:
        for(i in 0...8) {
          var deg = i * 360 / 8;
          var spd = 100;
          EnemyMgr.add(EnemyType.Bat, px, py, deg, spd);
        }
      case 400, 410, 420, 430, 440, 450:
        var deg = aim + 180 + FlxRandom.floatRanged(-60, 60);
        var spd = 100;
        EnemyMgr.add(EnemyType.Goast, px, py, deg, spd);
      case 600, 605, 610, 615, 620, 625, 630, 635, 640:
        var deg = aim + FlxRandom.floatRanged(-30, 30);
        var spd = 100 + e.level * 5;
        EnemyMgr.add(EnemyType.Bat2, px, py, deg, spd);
    }
    if(_timer > 800) {
      var spd = 50 + 5 * e.level;
      var dSpd = 10 + 2 * e.level;
      new FlxTimer(0.05, function(t:FlxTimer) {
        for(i in 0...3) {
          var deg2 = aim + -15 + i*15;
          e.bullet(deg2, spd);
        }
        spd += dSpd;
      }, 5);
      _timer = 0;
    }
  }
}
