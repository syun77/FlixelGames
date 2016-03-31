package jp_2dgames.game.token;

import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyMath;
import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 敵
 **/
class Enemy extends Token {

  public static var target:Player = null;

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(eid:Int, attr:Attribute, X:Float, Y:Float, deg:Float, speed:Float):Enemy {
    var e = parent.recycle(Enemy);
    e.init(eid, attr, X, Y, deg, speed);
    return e;
  }


  // ----------------------------------------------------------
  // ■フィールド
  var _eid:Int;  // 敵ID
  var _hp:Int;   // HP
  var _size:Int; // 半径
  var _attr:Attribute; // 属性
  var _timer:Int; // タイマー
  var _ai:EnemyAI;
  var _decay:Float = 1.0; // 移動の減衰値

  public var attribute(get, never):Attribute;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, attr:Attribute, X:Float, Y:Float, deg:Float, speed:Float):Void {
    _eid = eid;
    _attr = attr;
    x = X;
    y = Y;
    setVelocity(deg, speed);
    _size = EnemyInfo.getRadius(_eid)*2;
    _hp = EnemyInfo.getHp(_eid);
    color = AttributeUtil.toColor(attr);
    makeGraphic(_size, _size);
    _timer = 0;
    _decay = 1.0;

    // AI生成
    var script = AssetPaths.getAIScript(EnemyInfo.getAI(_eid));
    _ai = new EnemyAI(this, script);
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball2, xcenter, ycenter, AttributeUtil.toColor(_attr));
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

    if(isOutside()) {
      // 画面外に出たら消える
      kill();
    }
  }

  /**
   * ダメージを与える
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
   * 狙い撃ち角度を取得する
   **/
  public function getAim():Float {
    var dx = target.xcenter - xcenter;
    var dy = target.ycenter - ycenter;
    var deg = MyMath.atan2Ex(-dy, dx);
    return deg;
  }

  /**
   * 弾を撃つ
   **/
  public function bullet(deg:Float, speed:Float):Void {
    Bullet.add(_attr, xcenter, ycenter, deg, speed);
  }

  // ----------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return _size;
  }
  function get_attribute() {
    return _attr;
  }
}
