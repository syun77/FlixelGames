package jp_2dgames.game.token.enemy;
import flixel.util.FlxRandom;
import jp_2dgames.game.token.enemy.Enemy.EnemyType;
class BossGriffin extends BossJellyfish {

  var _degBat:Float;

  public function new(e:Enemy) {
    super(e);
    _degBat = e.getAim()-90;
  }
  override public function move(e:Enemy):Void {
    super.move(e);
  }
  override public function attack(e:Enemy):Void {
    var px = e.xcenter;
    var py = e.ycenter;
    var aim = e.getAim();

    if(_isBat()) {
      if(_timer%8 == 0) {
        EnemyMgr.add(EnemyType.Bat2, px-8, py-8, _degBat, 200);
      }
      _degBat += 0.5;
    }

    switch(_timer) {
      case 200:
        var deg = FlxRandom.intRanged(0, 360);
        var spd = 100;
        EnemyMgr.add(EnemyType.Skull, px, py, deg, spd);
    }

    if(_timer > 700) {
      var deg = aim - 180 + FlxRandom.floatRanged(-45, 45);
      var spd = 100;
      EnemyMgr.add(EnemyType.Fire, px, py, deg, spd);
      _timer = 0;
      _loop++;
      if(_loop >= 5) {
        // 5回ループで自爆
        e.kill();
      }
    }
  }

  function _isBat():Bool {
    if(_loop == 0 && _timer < 200) {
      return false;
    }
    return true;
  }
}
