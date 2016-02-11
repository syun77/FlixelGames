package jp_2dgames.game.token.enemy;
import flixel.util.FlxTimer;
class EnemyGoast3 extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 30;
  }

  override public function move(e:Enemy):Void {
    super.move(e);
    if(_timer > 450) {
      e.kill();
    }
  }

  override public function attack(e:Enemy):Void {

    if(_timer%120 != 0) {
      return;
    }

    var deg = e.getAim();
    var spd = 50 + 5 * e.level;
    new FlxTimer(0.05, function(t:FlxTimer) {
      e.bullet(deg, spd);
    }, 5);
  }
}
