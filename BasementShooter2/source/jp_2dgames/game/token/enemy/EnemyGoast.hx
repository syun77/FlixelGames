package jp_2dgames.game.token.enemy;

/**
 * ゴーストのAI
 **/
class EnemyGoast extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
    _speed = 10;
  }
  override public function attack(e:Enemy):Void {
    if(_timer%240 == 0) {
      var deg = e.getAim();
      for(i in 0...3) {
        e.bullet(deg+5-5*i, 30);
      }
    }
  }
}
