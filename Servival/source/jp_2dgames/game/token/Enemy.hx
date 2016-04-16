package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 敵
 **/
class Enemy extends Token {

  // ノックバックの速度
  static inline var KNOCKBACK_SPEED:Float = 400.0;

  static inline var TIMER_ATTACK:Int = 20; // 攻撃時の硬直時間
  static inline var TIMER_DAMAGE:Int = 60; // ダメージタイマー

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
  // 攻撃の硬直時間
  var _tAttack:Int = 0;
  // ダメージタイマー
  var _tDamage:Int = 0;

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
    _hp = EnemyInfo.getHp(_eid);
    animation.play('${_eid}');
    setVelocity(deg, speed);

    _timer = 0;
    _tAttack = 0;
    _tDamage = 0;
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
  public function damage(dir:Dir, val:Int):Void {

    if(_tDamage > 0) {
      // ダメージ中は攻撃を受けない
      return;
    }

    _hp--;
    if(_hp < 1) {
      // 死亡
      vanish();
    }

    // ダメージ中
    _tDamage = TIMER_DAMAGE;
    _tAttack = TIMER_ATTACK;

    // ノックバック
    var pt = DirUtil.getVector(dir);
    // ノックバックの速度を設定
    velocity.x = pt.x * KNOCKBACK_SPEED;
    velocity.y = pt.y * KNOCKBACK_SPEED;
    pt.put();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 画面内に入るようにする
    clipScreen();

    // ダメージタイマー更新
    _updateDamage();
    if(_tAttack > 0) {
      // 硬直中
      _tAttack--;
      if(_tAttack == 0) {
        // 硬直終了
        velocity.set();
      }
      return;
    }
    if(moves == false) {
      // 動けない
      return;
    }

    _timer++;
    if(_timer%60 == 0) {
      var aim = getAim();
      bullet(aim, 100);
    }
  }

  /**
   * ダメージタイマー更新
   **/
  function _updateDamage():Void {
    if(_tDamage > 0) {
      _tDamage--;
      if(_tDamage%4 < 2) {
        visible = true;
      }
      else {
        visible = false;
      }
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
