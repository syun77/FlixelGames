package jp_2dgames.game.state;
import flixel.addons.display.FlxStarField;
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

    var star = new FlxStarField3D();
    this.add(star);

    var txt = new FlxText(48, 24, 128, "HYPER RACER 2015", 24);
    txt.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.AQUAMARINE);
    this.add(txt);

    var bg = new FlxSprite(0, 200).makeGraphic(FlxG.width, 60, FlxColor.WHITE);
    bg.alpha = 0.3;
    this.add(bg);

    this.add(new FlxSprite(0, FlxG.height/2-120, Reg.PATH_IMAGE_TITLE));

    var px = FlxG.width/2;
    var py = FlxG.height/2 * 1.5;
    var btn = new FlxButton(px, py, "Click to START", function() {
      FlxG.switchState(new PlayInitState());
    });
    btn.x -= btn.width/2;
    btn.y -= btn.height/2;
    this.add(btn);

    var txtCopyright = new FlxText(0, FlxG.height-24, FlxG.width, "(c)2015 2dgames.jp");
    txtCopyright.alignment = "center";
    this.add(txtCopyright);
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
