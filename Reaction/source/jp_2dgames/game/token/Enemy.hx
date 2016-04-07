package jp_2dgames.game.token;

import jp_2dgames.game.global.Global;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * プレイヤーとの距離
 **/
enum EnemyDistance {
  Near; // 近い
  Mid;  // 中距離
  Far;  // 遠距離
}

/**
 * 状態
 **/
private enum State {
  Appear; // 出現
  Main;   // メイン
}

/**
 * 敵
 **/
class Enemy extends Token {

  static inline var TIMER_APPEAR:Int = 60;
  static inline var TIMER_HORMING:Int = 30;

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

  public static function distanceToInt(distance:EnemyDistance):Int {
    return switch(distance) {
      case EnemyDistance.Near: 1;
      case EnemyDistance.Mid:  2;
      case EnemyDistance.Far:  3;
    }
  }

  public static function countZaco():Int {
    var ret:Int = 0;
    parent.forEachAlive(function(e:Enemy) {
      switch(e._eid) {
        case 1, 2:
          ret++;
        default:
      }
    });
    return ret;
  }
  public static function countBoss():Int {
    var ret:Int = 0;
    parent.forEachAlive(function(e:Enemy) {
      switch(e._eid) {
        case 10, 11:
          ret++;
        default:
      }
    });
    return ret;
  }

  // ------------------------------------------------------
  // ■フィールド
  var _state:State;
  var _eid:Int;
  var _size:Float;
  var _width:Float;
  var _height:Float;
  var _timer:Int;
  var _hp:Int;
  var _ai:EnemyAI = null;
  var _score:Int;
  var _decay:Float = 1.0; // 移動の減衰値
  var _tDestroy:Float = 0.0; // 自爆タイマー
  var _bReflect:Bool; // 画面端で跳ね返るかどうか
  var _bAutoAngle:Bool; // 移動方向に自動で回転するかどうか

  // ホーミング用パラメータ
  var _deg:Float; // 移動方向
  var _speed:Float; // 移動速度
  var _dRot:Float; // 旋回速度


  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, X:Float, Y:Float, deg:Float, speed:Float):Void {
    _eid = eid;

    var sprite_name = EnemyInfo.getImage(eid);
    // TexturePackerData is a helper class to store links to atlas image and atlas data files
    var tex = FlxAtlasFrames.fromTexturePackerJson("assets/images/enemy.png", "assets/images/enemy.json");
    frames = tex;
    animation.frameName = sprite_name;
    resetSizeFromFrame();

    // AI読み込み
    var script_path = EnemyInfo.getAI(_eid);
    if(script_path == "none") {
      _ai = null;
    }
    else {
      var script = AssetPaths.getAIScript(EnemyInfo.getAI(_eid));
      _ai = new EnemyAI(this, script);
    }

    _size = EnemyInfo.getRadius(eid);
    _hp   = EnemyInfo.getHp(eid);
    _score = EnemyInfo.getScore(eid);
    _tDestroy = EnemyInfo.getDestroy(_eid);
    setVelocity(deg, speed);

    x = X - width/2;
    y = Y - height/2;

    _decay = 1.0;
    _bReflect = false;
    _bAutoAngle = false;
    angle = 0;

    _deg = deg;
    _speed = speed;
    _dRot = 5;

    _timer = TIMER_APPEAR;

    switch(_eid) {
      case 3, 4, 5:
        // だいこん・にんじん・ポッキーは出現演出なし
        _state = State.Main;
      case 6:
        // ホーミングにんじん
        _state = State.Main;
        _timer = TIMER_HORMING;
        setAutoAngle(true);
      default:
        _state = State.Appear;
    }
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Global.addScore(_score);
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    kill();
  }

  /**
   * 自爆
   **/
  public function selfDestruction():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Appear:
        // 出現
        velocity.x *= 0.95;
        velocity.y *= 0.95;
        _timer--;
        if(_timer < 1) {
          _state = State.Main;
        }

      case State.Main:
        // メイン
        _updateMain(elapsed);
    }
  }

  /**
   * 更新・メイン
   **/
  function _updateMain(elapsed:Float):Void {
    velocity.x *= _decay;
    velocity.y *= _decay;

    if(_bReflect) {
      // 反射あり
      _reflect();
    }
    if(_bAutoAngle) {
      // 自動回転あり
      var deg = MyMath.atan2Ex(-velocity.y, velocity.x);
      angle = 360 - deg;
    }

    if(_ai != null) {
      // AIスクリプト実行
      _ai.exec(elapsed);
    }
    else {
      // ホーミングする
      _horming();
    }

    _tDestroy -= elapsed;
    if(_tDestroy <= 0) {
      // 自爆
      selfDestruction();
      return;
    }
    if(isOutside()) {
      // 画面外に出たら消える
      kill();
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
   * ダメージ
   **/
  public function damage(val:Int):Void {
    _hp -= val;
    if(_hp < 1) {
      vanish();
    }
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
   * 画面端反射フラグを設定する
   **/
  public function setReflect(b:Bool):Void {
    _bReflect = b;
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
   * プレイヤーとの距離を判定
   **/
  public function getDistance():EnemyDistance {
    var distance = FlxMath.distanceBetween(_target, this);
    if(distance < 200) {
      return EnemyDistance.Near;
    }
    if(distance > 400) {
      return EnemyDistance.Far;
    }
    return EnemyDistance.Mid;
  }

  /**
   * プレイヤーとの距離に応じて移動方向を自動で決定
   **/
  public function move2(speed:Float):Void {
    var deg = getAim();
    switch(getDistance()) {
      case EnemyDistance.Near:
        // プレイヤーから離れる
        deg -= 180;
      case EnemyDistance.Mid:
        // プレイヤーを囲む
        if(FlxG.random.bool()) {
          deg += 90;
        }
        else {
          deg -= 90;
        }
      case EnemyDistance.Far:
        // プレイヤーに近づく
        deg = getAim();
    }
    setVelocity(deg, speed);
  }

  /**
   * 画面外で跳ね返る
   **/
  function _reflect():Void {
    if(x < 0) {
      x = 0;
      velocity.x *= -1;
    }
    if(y < 0) {
      y = 0;
      velocity.y *= -1;
    }
    var x2 = FlxG.width - width;
    var y2 = FlxG.height - height;
    if(x > x2) {
      x = x2;
      velocity.x *= -1;
    }
    if(y > y2) {
      y = y2;
      velocity.y *= -1;
    }
  }

  // ------------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return _size;
  }

  override public function get_xcenter() {
    var w = frame.frame.width;
    return x + w/2;
  }

  override public function get_ycenter() {
    var h = frame.frame.height;
    return y + h/2;
  }
}
