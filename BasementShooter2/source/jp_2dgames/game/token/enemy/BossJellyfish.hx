package jp_2dgames.game.token.enemy;

import jp_2dgames.game.token.enemy.Enemy;

import flixel.util.FlxRandom;
/**
 * クラゲAI
 **/
class BossJellyfish extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 15;
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

    if(_timer%240 == 200) {
      for(i in 0...8) {
        var deg = i * 360 / 8;
        var spd = 100;
        EnemyMgr.add(EnemyType.Bat, px, py, deg, spd);
      }
    }
  }
}
