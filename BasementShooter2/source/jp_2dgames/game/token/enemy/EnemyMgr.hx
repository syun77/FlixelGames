package jp_2dgames.game.token.enemy;
import flixel.group.FlxGroup;
import jp_2dgames.game.token.Boss;
import jp_2dgames.game.token.enemy.Enemy;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 敵管理
 **/
class EnemyMgr {

  public static var instance:FlxGroup = null;
  public static var enemies:FlxTypedGroup<Enemy> = null;
  public static var bosses:FlxTypedGroup<Boss> = null;

  public static function create(state:FlxState) {
    instance = new FlxGroup();
    state.add(instance);

    enemies = new FlxTypedGroup<Enemy>();
    bosses = new FlxTypedGroup<Boss>();

    instance.add(enemies);
    instance.add(bosses);
  }

  public static function destroy():Void {
    instance = null;
  }

  public static function add(type:EnemyType, X:Float, Y:Float, deg:Float=0.0, spd:Float=0.0):Enemy {
    var e:Enemy = enemies.recycle(Enemy);
    e.init(type, X, Y, deg, spd);
    return e;
  }

  public static function addBoss(type:BossType, X:Float, Y:Float):Boss {
    var boss:Boss = bosses.recycle(Boss);
    boss.init2(type, X, Y);
    return boss;
  }

  public static function countExists():Int {
    return instance.countLiving();
  }
}
