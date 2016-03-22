package jp_2dgames.game.particle;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import jp_2dgames.game.global.Global;

/**
 * レベル開始演出
 **/
class ParticleStartLevel {

  public static function start(state:FlxState):Void {
    // ステージ開始演出
    var fontsize = 16 * 2;
    var txt = new FlxText(0, FlxG.height*0.3, FlxG.width, 'LEVEL ${Global.level}', fontsize);
    if(Global.level == Global.MAX_LEVEL-1) {
      txt.text = "FINAL LEVEL";
    }
    txt.setFormat(null, fontsize, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    var px = txt.x;
    txt.x = -FlxG.width*0.75;
    FlxTween.tween(txt, {x:px}, 1, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
      var px2 = FlxG.width * 0.75;
      FlxTween.tween(txt, {x:px2}, 1, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
        // おしまい
        txt.kill();
      }});
    }});
    txt.scrollFactor.set();
    state.add(txt);
  }
}
