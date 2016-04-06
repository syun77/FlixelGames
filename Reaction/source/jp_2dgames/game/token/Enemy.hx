package jp_2dgames.game.token;

import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;
import flixel.graphics.frames.FlxAtlasFrames;
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

  // ------------------------------------------------------
  // ■フィールド
  var _eid:Int;
  var _size:Float;
  var _width:Float;
  var _height:Float;
  var _timer:Int;
  var _hp:Int;
  var _ai:EnemyAI = null;
  var _decay:Float = 1.0; // 移動の減衰値
  var _tDestroy:Float = 0.0; // 自爆タイマー
  var _bReflect:Bool; // 画面端で跳ね返るかどうか

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
    var script = AssetPaths.getAIScript(EnemyInfo.getAI(_eid));
    _ai = new EnemyAI(this, script);

    _size = EnemyInfo.getScore(eid);
    _hp   = EnemyInfo.getHp(eid);
    _tDestroy = EnemyInfo.getDestroy(_eid);
    setVelocity(deg, speed);

    _decay = 1.0;
    _bReflect = false;
    _timer = 0;
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
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

    velocity.x *= _decay;
    velocity.y *= _decay;

    if(_ai != null) {
      // AIスクリプト実行
      _ai.exec(elapsed);
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
   * 画面外で跳ね返る
   **/
  function _reflect():Void {
    // 左端では反射しない
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
}
