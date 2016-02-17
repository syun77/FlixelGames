package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import flixel.util.FlxColor;
import openfl._internal.aglsl.assembler.Part;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.token.Block;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

enum SwitchType {
  Red;
  Green;
  Blue;
  Yellow;
}

/**
 * スイッチ
 **/
class Switch extends Token {

  static inline var TIMER_TOUCH:Int = 16;

  public static var parent:FlxTypedGroup<Switch> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Switch>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:SwitchType, X:Float, Y:Float):Switch {
    var sw = parent.recycle(Switch);
    sw.init(type, X, Y);
    return sw;
  }
  public static function changeAll(type:SwitchType, b:Bool):Void {
    parent.forEachAlive(function(sw:Switch) {
      sw._change(type, b);
    });
  }

  // -------------------------------------------------
  // ■フィールド
  var _type:SwitchType;
  var _enable:Bool;
  var _tTouch:Int; // プレイヤー接触カウンタ

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SWITCH, true);
    _registerAnim();
  }

  public function init(type:SwitchType, X:Float, Y:Float):Void {
    _type = type;
    x = X;
    y = Y;
    _tTouch = 0;
    _enable = true;
    _playAnim();
  }

  override public function update():Void {
    super.update();
    if(_tTouch > 0) {
      _tTouch--;
    }
  }

  function _change(type:SwitchType, b:Bool):Void {
    if(_type == type) {
      _enable = b;
      _playAnim();
    }
  }

  function _getBlockType():BlockType {
    switch(_type) {
      case SwitchType.Red:    return BlockType.Red;
      case SwitchType.Green:  return BlockType.Green;
      case SwitchType.Blue:   return BlockType.Blue;
      case SwitchType.Yellow: return BlockType.Yellow;
    }
  }

  public function hit():Void {
    if(_tTouch > 0) {
      // 前フレームで接触しているので処理不要
      _tTouch = TIMER_TOUCH;
      return;
    }

    var enable = (_enable == false);
    Switch.changeAll(_type, enable);
    Block.changeAll(_getBlockType(), enable);
    _tTouch = TIMER_TOUCH;

    var c = _getColor();
    if(_enable) {
      Particle.start(PType.Ring, xcenter, ycenter, c);
      Snd.playSe("switchon");
    }
    else {
      Particle.start(PType.Ring3, xcenter, ycenter, c);
      Snd.playSe("switchoff");
    }
  }

  function _getColor():Int {
    switch(_type) {
      case SwitchType.Red: return FlxColor.RED;
      case SwitchType.Green: return FlxColor.LIME;
      case SwitchType.Blue: return FlxColor.AZURE;
      case SwitchType.Yellow: return FlxColor.YELLOW;
      default: return FlxColor.WHITE;
    }
  }

  function _registerAnim():Void {
    var enable = true;
    animation.add('${SwitchType.Red}${enable}',    [0], 1);
    animation.add('${SwitchType.Green}${enable}',  [1], 1);
    animation.add('${SwitchType.Blue}${enable}',   [2], 1);
    animation.add('${SwitchType.Yellow}${enable}', [3], 1);
    enable = false;
    animation.add('${SwitchType.Red}${enable}',    [4], 1);
    animation.add('${SwitchType.Green}${enable}',  [5], 1);
    animation.add('${SwitchType.Blue}${enable}',   [6], 1);
    animation.add('${SwitchType.Yellow}${enable}', [7], 1);
  }

  function _playAnim():Void {
    animation.play('${_type}${_enable}');
  }
}
