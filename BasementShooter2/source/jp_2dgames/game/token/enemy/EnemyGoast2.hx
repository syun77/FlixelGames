package jp_2dgames.game.token.enemy;
class EnemyGoast2 extends EnemyAI {
  public function new(e:Enemy) {
    super(e);
  }
  override public function move(e:Enemy):Void {
    // 動かない
    e.decayVelocity(0.97);
    if(_timer > 450) {
      e.kill();
    }
  }
  override public function attack(e:Enemy):Void {
    if(_timer < 80) {
      return;
    }

    var aim = e.getAim();
    if(_timer%90 == 0) {
      var spd = 80 + 5 * e.level;
      e.bullet(aim, spd);
    }
  }

}
