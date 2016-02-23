package jp_2dgames.game.token;

import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 敵
 **/
class Enemy extends Token {

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Enemy {
    var enemy = parent.recycle(Enemy);
    enemy.init(X, Y);
    return enemy;
  }

  // ------------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PERSON);
    color = FlxColor.LIME;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }

  /**
   * 消滅
   **/
  public function vanihs():Void {
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.LIME);
    kill();
  }
}
