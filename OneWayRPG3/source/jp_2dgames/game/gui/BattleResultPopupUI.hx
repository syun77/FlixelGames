package jp_2dgames.game.gui;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIPopup;

/**
 * バトルリザルト
 **/
class BattleResultPopupUI extends FlxUIPopup {

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "battle_result";
    super.create();
  }

  /**
   * 破棄
   **/
  public override function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  /**
   * イベントコールバック
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    var widget:IFlxUIWidget = cast sender;
    if(widget != null && Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          if(fuib.params != null) {
            var key = fuib.params[0];
            if(key == "ok") {
              // 閉じる
              close();
            }
          }
      }
    }
  }
}
