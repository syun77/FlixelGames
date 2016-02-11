package jp_2dgames.game.token.enemy;
import flixel.util.FlxRandom;
class EnemyFire extends EnemyAI{
  public function new(e:Enemy) {
    super(e);
    _speed = 100 + 20 * e.level;
  }

  override public function move(e:Enemy):Void {
    e.decayVelocity(0.97);
    if(_timer%200 == 0) {
      var aim = e.getAim();
      e.setVelocity(aim, _speed);
      _timer = FlxRandom.intRanged(0, 20);
    }
    if(_timer > 1000) {
      e.kill();
    }
  }
}
