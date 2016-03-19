package jp_2dgames.game.token;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flash.display.BlendMode;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * レーザー
 **/
class Laser extends FlxSpriteGroup {

  public static var _instance:Laser = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new Laser();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }

  public static function start(xc:Int, yc:Int):Void {
    _instance._start(xc, yc);
  }

  // -----------------------------------------------
  // ■フィールド
  var _horizon:FlxSprite;
  var _vertical:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _horizon = new FlxSprite(-FlxG.width, 0);
    _horizon.makeGraphic(FlxG.width*2, Field.GRID_SIZE, FlxColor.RED);
    _horizon.blend = BlendMode.ADD;
    this.add(_horizon);
    _vertical = new FlxSprite(0, -FlxG.height);
    _vertical.makeGraphic(Field.GRID_SIZE, FlxG.height*2, FlxColor.RED);
    _vertical.blend = BlendMode.ADD;
    this.add(_vertical);

    _horizon.kill();
    _vertical.kill();
    active = false;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _horizon.scale.y *= 0.9;
    _vertical.scale.x *= 0.9;
    if(_horizon.scale.y < 0.01) {
      _horizon.kill();
      _vertical.kill();
      active = false;
    }
  }

  /**
   * 演出開始
   **/
  function _start(xc:Int, yc:Int):Void {

    x = Field.toWorldX(xc);
    y = Field.toWorldY(yc);

    _horizon.revive();
    _vertical.revive();
    _horizon.scale.y = 1;
    _vertical.scale.x = 1;
    active = true;
  }
}
