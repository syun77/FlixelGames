package jp_2dgames.game.token.enemy;

/**
 * ウィル・オ・ウィスプのAI
 **/
import flixel.util.FlxRandom;
import jp_2dgames.game.token.enemy.Enemy.EnemyType;
class BossWillOWisp extends BossJellyfish {
  public function new(e:Enemy) {
    super(e);
  }

  /**
   * 移動
   **/
  override public function move(e:Enemy):Void {
    super.move(e);
  }

  /**
   * 攻撃
   **/
  override public function attack(e:Enemy):Void {
    var px = e.xcenter;
    var py = e.ycenter;
    var aim = e.getAim();

    switch(_timer) {
      case 200:
      for(i in 0...16) {
        var deg = i * 360 / 16;
        var spd = 100;
        EnemyMgr.add(EnemyType.Goast2, px, py, deg, spd);
      }
      case 350, 360, 370, 380, 390:
        var deg = aim - 180 + FlxRandom.floatRanged(-45, 45);
        var spd = 100;
        EnemyMgr.add(EnemyType.Fire, px, py, deg, spd);
    }
  }
}
