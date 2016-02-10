package jp_2dgames.game.token.enemy;

/**
 * コウモリのAI
 **/
import jp_2dgames.lib.MyMath;
class EnemyBat extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 100;
    _timer = 0;
  }

  override public function move(e:Enemy):Void {
    if(_timer < 90) {
      e.decayVelocity(0.97);
    }
    else if(_timer == 90) {
      var aim = e.getAim();
      e.velocity.x = _speed * MyMath.cosEx(aim);
      e.velocity.y = _speed * -MyMath.sinEx(aim);
    }
    else if(_timer > 300) {
      e.kill();
    }
  }

  override public function attack(e:Enemy):Void {
  }
}
