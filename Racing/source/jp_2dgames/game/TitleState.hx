package jp_2dgames.game;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxState;

/**
 * タイトル画面
 **/
class TitleState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var txt = new FlxText(48, 48, 128, "HYPER RACER 2015", 24);
    txt.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.AQUAMARINE);
    this.add(txt);

    this.add(new FlxSprite(0, 200).makeGraphic(FlxG.width, 60, FlxColor.SILVER));

    this.add(new FlxSprite(0, FlxG.height/2-120, Reg.PATH_IMAGE_TITLE));

    var px = FlxG.width/2;
    var py = FlxG.height/2 * 1.5;
    var btn = new FlxButton(px, py, "Click to START", function() {
      FlxG.switchState(new PlayState());
    });
    btn.x -= btn.width/2;
    btn.y -= btn.height/2;
    this.add(btn);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }
}
