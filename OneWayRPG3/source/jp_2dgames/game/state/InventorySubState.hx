package jp_2dgames.game.state;

import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.dat.ResistData.ResistList;
import flixel.addons.ui.FlxUIText;
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
  var _owner:SeqMgr;

  var _btnCancel:FlxUIButton;
  var _btnIgnore:FlxUIButton;
  var _btnItems:Map<String, FlxUIButton>;
  var _txtDetail:FlxUIText;

  /**
   * コンストラクタ
   **/
  public function new(mode:InventoryMode, owner:SeqMgr) {
    super();
    _mode = mode;
    _owner = owner;
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
        case "txtdetail":
          _txtDetail = cast widget;
        default:
          if(widget.name.indexOf("item") != -1) {
            var btn:FlxUIButton = cast widget;
            _btnItems[widget.name] = btn;
          }
      }

      if(Std.is(widget, FlxUIButton)) {
        // スライドイン表示
        var px = widget.x;
        widget.x = -widget.width*2;
        FlxTween.tween(widget, {x:px}, 0.5, {ease:FlxEase.expoOut, startDelay:idx*0.05});
        idx++;
      }
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
        case FlxUITypedButton.OVER_EVENT:
          // マウスが上に乗った
          if(fuib.params != null) {
            var key = fuib.params[0];
            _cbOver(key);
          }
      }
    }
  }

  /**
   * ボタンクリックのコールバック
   **/
  function _cbClick(name:String):Void {
    _owner.resetLastClickButton();
    _owner.setButtonClick(name);
    var idx = Std.parseInt(name);
    if(idx != null) {
      switch(_mode) {
        case InventoryMode.Battle:
          // アイテム使う
        case InventoryMode.ItemDrop:
          // アイテム捨てる
          var item = ItemList.getFromIdx(idx);
          ItemList.del(item.uid);
          var name = ItemUtil.getName(item);
          Message.push2(Msg.ITEM_DEL, [name]);
          // 食糧が増える
          _owner.addFood(item.now);
          _owner.startWait();
        case InventoryMode.ItemDropAndGet:
          // 捨てて拾う
          // TODO:
      }
    }

    // 何か押したら閉じる
    close();
  }

  /**
   * マウスオーバーのコールバック
   **/
  function _cbOver(name:String):Void {
    var idx = Std.parseInt(name);
    if(idx != null) {
      // 説明文の更新
      var item = ItemList.getFromIdx(idx);
      // 耐性情報を表示するかどうか
      var resists:ResistList = null;
      if(_mode == InventoryMode.Battle) {
        var enemy = _owner.enemy;
        resists = EnemyDB.getResists(enemy.id);
      }
      var detail = ItemUtil.getDetail2(_owner, item, resists);
      _setDetailText(detail);
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
   * アイテム説明文のテキストを設定
   **/
  function _setDetailText(msg:String):Void {
    _txtDetail.text = msg;
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
