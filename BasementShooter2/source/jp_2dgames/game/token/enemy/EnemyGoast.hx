package jp_2dgames.game.token.enemy;

/**
 * ゴーストのAI
 **/
class EnemyGoast extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 30;
  }
  override public function move(e:Enemy):Void {
    if(_timer < 90) {
      e.decayVelocity(0.97);
    }
    else if(_timer > 400) {
      e.kill();
    }
  }
  override public function attack(e:Enemy):Void {
    if(_timer%200 == 100) {
      var spd = 30 + 20 * e.level;
      var deg = e.getAim();
      for(i in 0...3) {
        e.bullet(deg+5-5*i, spd);
      }
    }

  }
}
