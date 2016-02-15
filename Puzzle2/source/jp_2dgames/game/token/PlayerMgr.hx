package jp_2dgames.game.token;
import flixel.group.FlxTypedGroup;
import jp_2dgames.game.token.Player;
import flixel.FlxState;

/**
 * プレイヤー管理
 **/
class PlayerMgr {

  public static var instance:FlxTypedGroup<Player> = null;

  public static function create(state:FlxState):Void {
    instance = new FlxTypedGroup<Player>();
    state.add(instance);
  }
  public static function destroy():Void {
    instance = null;
  }
  public static function createPlayer(X:Float, Y:Float):Void {
    var blue = new Player(X, Y, PlayerType.Blue);
    var red  = new Player(X, Y, PlayerType.Red);
    instance.add(blue);
    instance.add(red);
    blue.setActive(false);
    red.setActive(true);
  }
  public static function forEachAlive(func:Player->Void) {
    instance.forEachAlive(func);
  }

  public static function isActiveRed():Bool {
    var ret:Bool = false;
    forEachAlive(function(player:Player) {
      if(player.isActive()) {
        ret = (player.type == PlayerType.Red);
      }
    });
    return ret;
  }
  public static function getActiveType():PlayerType {
    return isActiveRed() ? PlayerType.Red : PlayerType.Blue;
  }

  public static function get(type:PlayerType):Player {
    var ret:Player = null;
    forEachAlive(function(player:Player) {
      if(type == player.type) {
        ret = player;
      }
    });
    return ret;
  }
  public static function getActive():Player {
    var ret:Player = null;
    forEachAlive(function(player:Player) {
      if(player.isActive()) {
        ret = player;
      }
    });
    return ret;
  }

  public static function toggle():Void {
    var type = getActiveType();
    forEachAlive(function(player:Player) {
      player.setActive(type != player.type);
    });
  }

  public function new() {
  }
}
