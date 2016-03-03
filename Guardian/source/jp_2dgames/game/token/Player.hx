package jp_2dgames.game.token;
import flixel.FlxG;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Enemy.EnemyType;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var SPEED_DECAY:Float = 0.1 * 60;
  public static inline var MARGIN:Int = 32;
  public static inline var SIZE:Int = 16;

  var _xtarget:Float;
  var _ytarget:Float;
  var _type:EnemyType = EnemyType.Blue;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {

    X -= SIZE/2;
    Y -= SIZE/2;

    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER);

    _xtarget = X;
    _ytarget = Y;

  }

  /**
   * 初期化
   **/
  public function init():Void {
    _changeType();
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);

    FlxG.camera.shake(0.05, 0.4);
    FlxG.camera.flash(FlxColor.WHITE, 0.5);

    kill();
  }

  /**
   * 同一色かどうか
   **/
  public function isSame(type:EnemyType):Bool {
    return _type == type;
  }

  /**
   * ダメージ処理
   **/
  public function damage():Void {
    // 死亡
    vanish();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _move();

    if(Input.press.A) {
      // 色変え
      _changeType();
    }
  }

  function _move():Void {
    // 移動範囲制限
    var mx = Input.mouse.x;
    var my = Input.mouse.y;
    if(mx < MARGIN) { mx = MARGIN; }
    if(my < MARGIN) { my = MARGIN; }
    if(mx > FlxG.width-MARGIN) { mx = FlxG.width-MARGIN; }
    if(my > FlxG.height-MARGIN) { my = FlxG.height-MARGIN; }

    _xtarget = mx - width/2;
    _ytarget = my - height/2;

    var vx = (_xtarget - x) * SPEED_DECAY;
    var vy = (_ytarget - y) * SPEED_DECAY;
    velocity.set(vx, vy);
  }

  function _changeType():Void {
    switch(_type) {
      case EnemyType.Red:   _type = EnemyType.Green;
      case EnemyType.Green: _type = EnemyType.Blue;
      case EnemyType.Blue:  _type = EnemyType.Red;
    }

    color = Enemy.typeToColor(_type);
    Particle.start(PType.Ring, xcenter, ycenter, color);
  }

  override public function get_radius() {
    return 8;
  }
}
