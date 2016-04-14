package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

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
  public static function add(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Enemy {
    var e = parent.recycle(Enemy);
    e.init(eid, X, Y, deg, speed);
    return e;
  }

  // ----------------------------------------------------------
  // ■アクセサ
  var _eid:Int;
  var _hp:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 32, 32);
    _registerAnim();
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Void {
    x = X;
    y = Y;
    _eid = eid;
    // TODO:
    _hp = 0;
    animation.play('${_eid}');
    setVelocity(deg, speed);
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.GREEN);

    kill();
  }

  /**
   * ダメージを与える
   **/
  public function damage(val:Int):Void {
    _hp--;
    if(_hp < 1) {
      // 死亡
      vanish();
    }
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    for(i in 0...5) {
      var v = i * 4;
      animation.add('${i+1}', [v, v+1], 4);
    }
  }
}
