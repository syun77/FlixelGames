package jp_2dgames.game.token.enemy;

/**
 * コウモリのAI
 **/
class EnemyBat extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 10;
  }
  override public function attack(e:Enemy):Void {
  }
}
