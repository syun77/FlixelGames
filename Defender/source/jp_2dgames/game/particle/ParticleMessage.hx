package jp_2dgames.game.particle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

/**
 * メッセージ
 **/
class ParticleMessage extends FlxText {

  static inline var TIMER_DESTROY:Int = 60;

  public static var parent:FlxTypedGroup<ParticleMessage> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleMessage>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, txt:String):ParticleMessage {
    var msg = parent.recycle(ParticleMessage);
    msg.init(X, Y, txt);
    return msg;
  }

  // --------------------------------------------------------
  // ■フィールド
  var _tDestroy:Int;

  public function new() {
    super(0, 0, 128);
  }

  public function init(X:Float, Y:Float, msg:String):Void {
    x = X-128/2;
    y = Y;
    text = msg;
    alignment = "center";
    _tDestroy = TIMER_DESTROY;
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tDestroy--;
    if(_tDestroy < 1) {
      kill();
    }
  }
}
