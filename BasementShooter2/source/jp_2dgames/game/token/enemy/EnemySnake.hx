package jp_2dgames.game.token.enemy;
import flixel.FlxObject;

/**
 * へびのAI
 **/
class EnemySnake extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 50 + 5 + e.level;
    e.acceleration.y = Enemy.GRAVITY;
  }
  override public function move(e:Enemy):Void {
    if(e.isTouching(FlxObject.FLOOR)) {
      // 着地しているときだけ移動
      super.move(e);
    }
    else {
      e.velocity.x = 0;
    }

    if(e.velocity.x == 0) {
    }
    else if(e.velocity.x < 0) {
      e.flipX = false;
    }
    else {
      e.flipX = true;
    }

    if(_timer > 400) {
      e.kill();
    }
  }
}
