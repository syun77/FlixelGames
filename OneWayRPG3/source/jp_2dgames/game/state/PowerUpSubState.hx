package jp_2dgames.game.state;

import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUISubState;

/**
 * メインゲーム強化メニュー
 **/
class PowerUpSubState extends FlxUISubState {

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "powerup";
    super.create();
  }

  /**
   * 破棄
   **/
  public override function destroy():Void {
    super.destroy();
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    var widget:IFlxUIWidget = cast sender;
    if(widget != null && Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          // ボタンパラメータを判定
          if(fuib.params != null) {
            var key = fuib.params[0];
            if(key == "close") {
              close();
            }
          }
      }
    }
  }
}
