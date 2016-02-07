package jp_2dgames.game.token;
class EnemyAI {
  private var _timer:Int;
  private var _speed:Float;
  public function new(e:Enemy) {
    _timer = 0;
    _speed = 0;
  }
  public function proc():Void {
    _timer++;
  }
  public function move(e:Enemy):Void {
    var deg = e.getAim();
    e.setVelocity(deg, _speed);
  }
  public function attack(e:Enemy):Void {
  }
}
