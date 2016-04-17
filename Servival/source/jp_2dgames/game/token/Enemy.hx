package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 飛行属性
 **/
enum EnemyFly {
  None; // なし
  Fly;  // 飛行
  Wall; // 壁抜け
}

/**
 * 敵
 **/
class Enemy extends Token {

  // ノックバックの速度
  static inline var KNOCKBACK_SPEED:Float = 400.0;

  static inline var TIMER_ATTACK:Int = 20; // 攻撃時の硬直時間
  static inline var TIMER_DAMAGE:Int = 60; // ダメージタイマー
  static inline var TIMER_HORMING:Int = 60;
  // コリジョンサイズ
  static inline var COLLISION_WIDTH:Int = 20;
  static inline var COLLISION_HEIGHT:Int = 20;

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
  // AI
  var _ai:EnemyAI;
  // 移動量減衰値
  var _decay:Float;
  var _bAutoAngle:Bool; // 移動方向に自動で回転するかどうか
  var _fly:EnemyFly; // 飛行属性
  public var fly(get, never):EnemyFly;
  var _bReflect:Bool;
  var _vxprev:Float;
  public var vxprev(get, never):Float;
  var _vyprev:Float;
  public var vyprev(get, never):Float;

  // ホーミング用パラメータ
  var _deg:Float; // 移動方向
  var _speed:Float; // 移動速度
  var _dRot:Float; // 旋回速度

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
    _fly = _toFly(EnemyInfo.getFly(_eid));
    animation.play('${_eid}');
    setVelocity(deg, speed);

    // コリジョンサイズ調整
    {
      var w = width;
      var h = height;
      var ow = (w-COLLISION_WIDTH)/2;
      var oh = (h-COLLISION_HEIGHT)/2;
      width = COLLISION_WIDTH;
      height = COLLISION_HEIGHT;
      offset.set(ow, oh);
    }

    // AI読み込み
    var script_path = EnemyInfo.getAI(_eid);
    if(script_path == "none") {
      _ai = null;
      _bAutoAngle = true;
      _timer = TIMER_HORMING;
    }
    else {
      var script = AssetPaths.getAIScript(EnemyInfo.getAI(_eid));
      _ai = new EnemyAI(this, script);
      _bAutoAngle = false;
      _timer = 0;
    }

    _tAttack = 0;
    _tDamage = 0;
    _decay = 1.0;
    angle = 0;
    _bReflect = false;

    _deg = deg;
    _speed = speed;
    _dRot = 2;

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

    if(_hp == -1) {
      // 無敵
      return;
    }

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

    _vxprev = velocity.x;
    _vyprev = velocity.y;

    velocity.x *= _decay;
    velocity.y *= _decay;

    // 画面内に入るようにする
    if(clipScreen()) {
      if(_ai == null) {
        vanish();
      }
    }

    if(_ai != null) {
      // AIスクリプト実行
      _ai.exec(elapsed);
    }
    else {
      // ホーミングする
      _horming();
    }

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

    if(_bAutoAngle) {
      // 自動回転あり
      var deg = MyMath.atan2Ex(-velocity.y, velocity.x);
      angle = 360 - deg;
    }

    /*
    _timer++;
    if(_timer%60 == 0) {
      var aim = getAim();
      bullet(aim, 100);
    }
    */
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
   * ホーミング
   **/
  function _horming():Void {
    if(_target == null) {
      return;
    }
    if(_target.exists == false) {
      // ターゲットが消滅した
      return;
    }
    _timer--;
    if(_timer < 1) {
      // ホーミング無効
      return;
    }
    var dx = _target.xcenter - xcenter;
    var dy = _target.ycenter - ycenter;
    var aim = MyMath.atan2Ex(-dy, dx);
    var d = MyMath.deltaAngle(_deg, aim);
    var sign = if(d > 0) 1 else -1;
    _deg += _dRot * sign;
    _dRot += 0.1;
    setVelocity(_deg, _speed);
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
   * 減衰値を設定する
   **/
  public function setDecay(decay:Float):Void {
    _decay = decay;
  }

  /**
   * 移動方向に自動で回転するのを有効にする
   **/
  public function setAutoAngle(b:Bool):Void {
    _bAutoAngle = b;
  }

  /**
   * 反射を有効にする
   **/
  public function setReflect(b:Bool):Void {
    _bReflect = b;
  }

  public function isReflect():Bool {
    return _bReflect;
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    for(i in 0...9) {
      var v = i * 4;
      var id = i + 1;
      if(id == 7) {
        animation.add('${id}', [v, v+1, v+2, v+3], 4);
      }
      else {
        animation.add('${id}', [v, v+1], 4);
      }
    }
  }

  /**
   * 飛行属性文字列をenumに変換する
   **/
  function _toFly(str:String):EnemyFly {
    return switch(str) {
      case "fly": EnemyFly.Fly;
      case "wall": EnemyFly.Wall;
      default: EnemyFly.None;
    }
  }

  // -----------------------------------------------------------
  // ■アクセサ
  function get_fly() {
    return _fly;
  }
  function get_vxprev() {
    return _vxprev;
  }
  function get_vyprev() {
    return _vyprev;
  }
}
