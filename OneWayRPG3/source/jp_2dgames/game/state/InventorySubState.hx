package jp_2dgames.game.state;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemList;
import flixel.addons.ui.FlxUITypedButton;
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
    _ui.setMode(_modeToName());

    _btnItems = new Map<String, FlxUIButton>();

    var idx:Int = 0;
    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "cancel":
          _btnCancel = cast widget;
        case "ignore":
          _btnIgnore = cast widget;
        default:
          if(widget.name.indexOf("item") != -1) {
            var btn:FlxUIButton = cast widget;
            _btnItems[widget.name] = btn;
          }
      }

      // スライドイン表示
      var px = widget.x;
      widget.x = -widget.width*2;
      FlxTween.tween(widget, {x:px}, 0.5, {ease:FlxEase.expoOut, startDelay:idx*0.05});
      idx++;
    });

    // 表示項目を更新
    _updateItems();
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
            _cbClick(key);
          }
      }
    }
  }

  /**
   * ボタンクリックのコールバック
   **/
  function _cbClick(name:String):Void {
    switch(name) {
      case "cancel":
        // 閉じる
        close();
    }
  }

  /**
   * 表示アイテムを更新
   **/
  function _updateItems():Void {
    for(i in 0...ItemList.MAX) {
      var item = ItemList.getFromIdx(i);
      var key = 'item${i}';
      var btn:FlxUIButton = _btnItems[key];
      if(item == null) {
        // 所持していないので非表示
        btn.visible = false;
        continue;
      }
      // 表示する
      btn.visible = true;
      var name = ItemUtil.getName(item);
      btn.label.text = name;
      // 属性アイコンを設定
      var attr = ItemUtil.getAttribute(item);
      var icon = AttributeUtil.getIconPath(attr);
      btn.removeIcon();
      if(icon != "") {
        var spr = new FlxSprite(0, 0, icon);
        btn.addIcon(spr, -8, -6, false);
      }
    }
  }

  /**
   * モードに対応する名前を取得する
   **/
  function _modeToName():String {
    return switch(_mode) {
      case InventoryMode.Battle: "battle";
      case InventoryMode.ItemDrop: "drop";
      case InventoryMode.ItemDropAndGet: "dropandget";
    }
  }
}
