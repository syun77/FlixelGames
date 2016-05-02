package jp_2dgames.game.state;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

/**
 * エンディング画面
 **/
class EndingState extends FlxState {

  static inline var PLAYER_16x16:Bool = true; // プレイヤーが16x16のサイズかどうか
  static inline var FONT_SIZE:Int = 8 * 1;

  override public function create():Void {
    super.create();

    var txt = new FlxText(0, 64, FlxG.width, "Congratulation!", FONT_SIZE * 3);
    txt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 2);
    txt.alignment = "center";
    this.add(txt);
    var msg = new FlxText(0, 128, FlxG.width, "completed all of the levels.", FONT_SIZE);
    msg.alignment = "center";
    this.add(msg);

    if(false)
    {
      var player = new FlxSprite(0, FlxG.height - 64);
      player.loadGraphic(AssetPaths.IMAGE_PLAYER, true);

      if(PLAYER_16x16) {
        // 16x16のプレイヤー
        player.animation.add("play", [2, 3], 8);
      }
      else {
        // 32x32のプレイヤー
        player.animation.add('play', [10, 11], 6);
      }
      player.animation.play("play");
      var func = function(x:Float) return x;
      FlxTween.tween(player, {x:FlxG.width+32}, 6, {ease:func, onComplete:function(tween:FlxTween) {
        FlxG.switchState(new TitleState());
      }});
      this.add(player);
    }
    else {
      // タイトルに戻るボタン
      var btn = new FlxButton(0, FlxG.height*0.8, "Back to TITLE", function() {
        FlxG.switchState(new TitleState());
      });
      btn.x = FlxG.width/2 - btn.width/2;
      this.add(btn);

    }
  }

  override public function destroy():Void
  {
    super.destroy();
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
  }
}
