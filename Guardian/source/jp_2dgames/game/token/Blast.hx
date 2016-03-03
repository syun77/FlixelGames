package jp_2dgames.game.token;
import jp_2dgames.game.token.Enemy;
import flixel.FlxG;
import flixel.FlxBasic.FlxType;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flash.display.BlendMode;

private enum State {
  Start;
  Main;
  Vanish;
}

/**
 * 爆風
 **/
class Blast extends Token {

  static inline var TIMER_START:Int = 10;
  static inline var TIMER_MAIN:Int = 1;
  static inline var TIMER_VANISH:Int = 10;

  // 爆風生存数のキャッシュ
  static var _countExistsCache:Int = 0;
  public static function countExistCache():Void {
    _countExistsCache = parent.countLiving();
  }
  public static function getCountExistsCache():Int {
    return _countExistsCache;
  }

  public static var parent:FlxTypedGroup<Blast> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Blast>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:EnemyType, X:Float, Y:Float):Void {
    var blast = parent.recycle(Blast);
    blast.init(type, X, Y);
  }

  // ------------------------------------------------------------
  // ■フィールド
  var _state:State;
  var _timer:Int = 0;
  var _type:EnemyType;
  public var type(get, never):EnemyType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLAST);
    blend = BlendMode.ADD;
  }

  /**
   * 初期化
   **/
  public function init(type:EnemyType, X:Float, Y:Float):Void {
    x = X - width/2;
    y = Y - height/2;
    _timer = TIMER_START;
    _type = type;
    scale.set(0.001, 0.001);
    alpha = 1;
    color = Enemy.typeToColor(type);
    _state = State.Start;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Start:
        var sc = 1.0 / TIMER_START;
        scale.x += sc;
        scale.y += sc;
        _timer--;
        if(_timer < 1) {
          _timer = TIMER_MAIN;
          _state = State.Main;
        }
      case State.Main:
        var sc = FlxG.random.float(0.9, 1);
        scale.set(sc, sc);
        alpha = FlxG.random.float(0.9, 1);
        _timer--;
        if(_timer < 1) {
          _state = State.Vanish;
          _timer = TIMER_VANISH;
        }
      case State.Vanish:
        _timer--;
        scale.x *= 0.97;
        scale.y *= 0.97;
        alpha *= 0.97;
        if(_timer < 1) {
          kill();
        }
    }
  }

  override public function get_radius() {
    return 36 * scale.x;
  }

  function get_type() {
    return _type;
  }
}
