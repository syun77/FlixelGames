package jp_2dgames.game.token;

import jp_2dgames.lib.MyMath;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 敵
 **/
class Enemy extends Token {

  static var _target:Player = null;
  public static function setTarget(target:Player):Void {
    _target = target;
  }

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
  var _timer:Int = 0;

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

    _timer = 0;
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
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _timer++;
    if(_timer%60 == 0) {
      var aim = getAim();
      bullet(aim, 100);
    }
  }

  /**
   * 弾を撃つ
   **/
  public function bullet(deg:Float, speed:Float):Void {
    bullet2(0, 0, deg, speed);
  }
  public function bullet2(xofs:Float, yofs:Float, deg:Float, speed:Float):Void {
    var px = xcenter + xofs;
    var py = ycenter + yofs;
    Bullet.add(px, py, deg, speed);
  }

  /**
   * 狙い撃ち角度を取得する
   **/
  public function getAim():Float {
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    return MyMath.atan2Ex(-dy, dx);
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
