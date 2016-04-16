package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import flash.display.BlendMode;
import flixel.tweens.FlxEase;
import flixel.FlxState;

/**
 * ショット
 **/
class Shot extends Token {

  static inline var TIMER_DESTROY:Int = 30;

  public static var parent:TokenMgr<Shot> = null;
  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr<Shot>(16, Shot);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(id:Int, X:Float, Y:Float, deg:Float, speed:Float):Shot {
    var shot:Shot = parent.recycle();
    shot.init(id, X, Y, deg, speed);
    return shot;
  }

  // ------------------------------------------------------
  // ■フィールド
  var _tDestroy:Int; // 消滅タイマー
  var _dir:Dir; // 方向
  public var dir(get, never):Dir;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHOT, true);
    animation.add("play", [0, 1], 8);
    animation.play("play");
    blend = BlendMode.ADD;
    kill();
  }

  /**
   * 初期化
   **/
  public function init(id:Int, X:Float, Y:Float, deg:Float, speed:Float):Void {
    x = X;
    y = Y;
    setVelocity(deg, speed);
    scale.set(1, 1);
    _tDestroy = TIMER_DESTROY;
    _dir = DirUtil.fromAngle(deg);
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    super.kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var sc = FlxEase.expoOut(_tDestroy/TIMER_DESTROY);
    scale.set(sc, sc);
    _tDestroy--;
    if(_tDestroy < 1) {
      kill();
    }
  }


  // -----------------------------------------------------
  // ■アクセサ
  public function get_dir() {
    return _dir;
  }
}
