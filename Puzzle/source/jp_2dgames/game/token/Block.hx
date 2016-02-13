package jp_2dgames.game.token;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import jp_2dgames.game.util.Field;
import flixel.FlxState;
import jp_2dgames.lib.Snd;

/**
 * 状態
 **/
private enum State {
  Fixied;  // 停止中
  Falling; // 落下中
}

/**
 * ブロック管理
 **/
class Block extends Token {

  static inline var GRAVITY:Float = 400.0;

  public static var parent:FlxTypedGroup<Block> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>(Field.WIDTH * Field.HEIGHT);
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(i:Int, j:Int):Block {
    var block:Block = parent.recycle(Block);
    block.init(i, j);
    return block;
  }

  // =======================================================================
  // ■フィールド
  var _state:State;
  public var xgrid(get, null):Int;
  public var ygrid(get, null):Int;
  function get_xgrid() {
    return Std.int(x / Field.WIDTH);
  }
  function get_ygrid() {
    return Std.int(y / Field.HEIGHT);
  }

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK);
    acceleration.y = GRAVITY;
    maxVelocity.y = GRAVITY;
    maxVelocity.x = 1;
    mass = 1000000;
  }

  public function init(i:Int, j:Int):Void {
    x = Field.toWorldX(i);
    y = Field.toWorldY(j);
    ID = (j * Field.WIDTH) + i;

    // 落下開始
    startFall();
  }

  public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.BROWN);
    kill();
    Snd.playSe("damage", true);
  }

  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Fixied:
      case State.Falling:
    }
  }

  public function snapGrip():Void {
    x = Std.int(x / Field.TILE_WIDTH) * Field.TILE_WIDTH;
    y = Std.int(y / Field.TILE_HEIGHT) * Field.TILE_HEIGHT;
    velocity.x = 0;
    velocity.y = 0;
  }

  public function startFall():Void {
    acceleration.y = GRAVITY;
    _state = State.Falling;
  }

  public function stop(py:Float):Void {
    _state = State.Fixied;
    y = py;
    acceleration.y = 0;
    velocity.y = 0;
  }
}
