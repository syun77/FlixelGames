package jp_2dgames.game;
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

    var px = FlxG.width/2;
    var py = FlxG.height/2;
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
