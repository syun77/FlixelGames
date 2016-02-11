package jp_2dgames.game.token.enemy;

/**
 * コウモリのAI
 **/
class EnemyBat2 extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 100;
    _timer = 0;
  }

  override public function move(e:Enemy):Void {
    if(_timer > 300) {
      e.kill();
    }
  }

  override public function attack(e:Enemy):Void {
  }
}
