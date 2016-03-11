package jp_2dgames.game.token;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * エネルギーボール
 **/
class Energy extends Token {

  public static var parent:FlxTypedGroup<Energy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Energy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, xtarget:Float, ytarget:Float, cbEnd:Void->Void):Energy {
    var energy = parent.recycle(Energy);
    energy.init(X, Y, xtarget, ytarget, cbEnd);
    return energy;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_EFFECT2, true);
    animation.add("play", [0], 1);
    animation.play("play");
    blend = BlendMode.ADD;

    offset.x += width/2;
    offset.y += height/2;
  }

  public function init(X:Float, Y:Float, xtarget:Float, ytarget:Float, cbEnd:Void->Void):Void {

    x = X;
    y = Y;
    var func = function() {
      return switch(FlxG.random.int(0, 2)) {
        case 0: FlxEase.backIn;
        case 1: FlxEase.backOut;
        default: FlxEase.backInOut;
      }
    }

    var funcX = FlxEase.sineIn;
    var funcY = FlxEase.sineOut;
    if(FlxG.random.bool(50)) {
      funcX = func();
    }
    else {
      funcY = func();
    }
    var speed = FlxG.random.float(0.4, 0.5);
    FlxTween.tween(this, {x:xtarget}, speed, {ease:funcX});
    FlxTween.tween(this, {y:ytarget}, speed, {ease:funcY, onComplete:function(tween:FlxTween) {
      kill();
      if(cbEnd != null) {
        cbEnd();
      }
    }});
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {

    super.update(elapsed);

    alpha = FlxG.random.float(0.6, 0.8);
    var sc = FlxG.random.float(0.8, 1);
    scale.set(sc, sc);
  }


}
