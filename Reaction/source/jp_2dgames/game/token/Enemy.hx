package jp_2dgames.game.token;

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

    _size = EnemyInfo.getScore(eid);
    _hp   = EnemyInfo.getHp(eid);
    setVelocity(deg, speed);

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
   * ダメージ
   **/
  public function damage(val:Int):Void {
    _hp -= val;
    if(_hp < 1) {
      vanish();
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


  // ------------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return _size;
  }
}
