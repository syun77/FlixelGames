package jp_2dgames.game.token;
import jp_2dgames.lib.Snd;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import jp_2dgames.game.token.Player;
import flixel.FlxState;

/**
 * プレイヤー管理
 **/
class PlayerMgr {

  public static var instance:FlxTypedGroup<Player> = null;
  public static var group:FlxGroup = null;

  // 生成
  public static function create(state:FlxState):Void {
    group = new FlxGroup();
    state.add(group);
    instance = new FlxTypedGroup<Player>();
    state.add(instance);
  }
  // 破棄
  public static function destroy():Void {
    instance = null;
    group = null;
  }
  // プレイヤーの生成
  public static function createPlayer(X:Float, Y:Float):Void {
    var blue = new Player(X, Y, PlayerType.Blue);
    var red  = new Player(X, Y, PlayerType.Red);
    group.add(red.getLight());
    group.add(blue.getLight());
    group.add(red.getTrail());
    group.add(blue.getTrail());
    instance.add(blue);
    instance.add(red);
    blue.setActive(false);
    red.setActive(true);
  }
  // まとめて処理する
  public static function forEachAlive(func:Player->Void) {
    instance.forEachAlive(func);
  }

  // 赤がアクティブかどうか
  public static function isActiveRed():Bool {
    var ret:Bool = false;
    forEachAlive(function(player:Player) {
      if(player.isActive()) {
        ret = (player.type == PlayerType.Red);
      }
    });
    return ret;
  }
  // アクティブになっている種別を取得する
  public static function getActiveType():PlayerType {
    return isActiveRed() ? PlayerType.Red : PlayerType.Blue;
  }

  // 指定した種別のプレイヤーを取得する
  public static function get(type:PlayerType):Player {
    var ret:Player = null;
    forEachAlive(function(player:Player) {
      if(type == player.type) {
        ret = player;
      }
    });
    return ret;
  }
  // アクティブになっているプレイヤーインスタンスを取得する
  public static function getActive():Player {
    var ret:Player = null;
    forEachAlive(function(player:Player) {
      if(player.isActive()) {
        ret = player;
      }
    });
    return ret;
  }
  // 非アクティブになっているプレイヤーを取得する
  public static function getNonActive():Player {
    var ret:Player = null;
    forEachAlive(function(player:Player) {
      if(player.isActive() == false) {
        ret = player;
      }
    });
    return ret;
  }

  // プレイヤーを切り替える
  public static function toggle():Void {
    var type = getActiveType();
    forEachAlive(function(player:Player) {
      player.setActive(type != player.type);
    });

    // カメラ移動
    lockCameraActive();
    Snd.playSe("shot");
  }

  // アクティブなプレイヤーにカメラをロックする

  public static function lockCameraActive():Void {
    var player = getActive();
    var lerp = 5; // 補完速度
    FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER, null, lerp);
  }

  public function new() {
  }
}
