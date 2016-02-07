package jp_2dgames.game.token.enemy;

import flixel.util.FlxTimer;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxRandom;

/**
 * ドクロのAI
 **/
class EnemySkull extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 15;
  }

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
    if(_timer%240 == 200) {
      var deg = e.getAim();
      switch(e.getDistType()) {
        case Enemy.DIST_NEAR:
          // 近距離:ゆっくり3WAYを撃つ
          for(i in 0...3) {
            e.bullet(deg+5-5*i, 30);
          }
        case Enemy.DIST_MID:
          // 中距離:
          var spd = 50;
          var dSpd = 10;
          new FlxTimer(0.05, function(t:FlxTimer) {
            for(i in 0...3) {
              var deg2 = deg + -15 + i*15;
              e.bullet(deg2, spd);
            }
            spd += dSpd;
          }, 5);
        case Enemy.DIST_FAR:
          // 長距離:
          for(i in 0...16) {
            var rot = i * 360 / 16;
            var ox = 32 * MyMath.cosEx(rot);
            var oy = 32 * MyMath.sinEx(rot);
            var deg2 = e.getAim(ox, oy);
            e.bulletOfs(ox, oy, deg2, 150);
          }
      }
    }
  }
}
