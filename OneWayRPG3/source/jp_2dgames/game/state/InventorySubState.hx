package jp_2dgames.game.state;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import jp_2dgames.game.gui.BattleUI.InventoryMode;
import flixel.addons.ui.FlxUISubState;

/**
 * インベントリSubState
 **/
class InventorySubState extends FlxUISubState {

  // ----------------------------------------
  // ■フィールド
  var _mode:InventoryMode;

  var _btnCancel:FlxUIButton;
  var _btnIgnore:FlxUIButton;
  var _btnItems:Map<String, FlxUIButton>;

  /**
   * コンストラクタ
   **/
  public function new(mode:InventoryMode) {
    super();
    _mode = mode;
  }

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "inventory";
    super.create();

    _btnItems = new Map<String, FlxUIButton>();

    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "cancel":
          _btnCancel = cast widget;
        case "ignore":
          _btnIgnore = cast widget;
        default:
          if(Std.is(widget, FlxUIButton)) {
            var btn:FlxUIButton = cast widget;
            _btnItems[widget.name] = btn;
          }
      }
    });
  }

  /**
   * 破棄
   **/
  public override function destroy():Void {
    super.destroy();
  }
}
