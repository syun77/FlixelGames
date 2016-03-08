package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * コイン
 **/
class Coin extends Token {

  static inline var TIMER_DESTROY:Int = 5 * 60;

  public static var parent:FlxTypedGroup<Coin> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Coin>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Coin {
    var coin = parent.recycle(Coin);
    coin.init(X, Y);
    return coin;
  }

  // -------------------------------------------------------
  // ■フィールド
  var _tDestroy:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_COIN, true);
    animation.add("play", [0, 1], 4);
    animation.play("play");
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _tDestroy = TIMER_DESTROY;
    setVelocity(FlxG.random.float(0, 360), 50);
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball2, xcenter, ycenter, FlxColor.YELLOW);
    // スコア加算
    Global.addScore(10);
    Snd.playSe("item");
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var decay = 0.97;
    velocity.x *= decay;
    velocity.y *= decay;

    _tDestroy--;
    if(_tDestroy < 1 * 60) {
      visible = _tDestroy%4 < 2;
    }

    if(_tDestroy < 0) {
      kill();
    }
  }

}
