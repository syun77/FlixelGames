package jp_2dgames.game.gui;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.lib.Input;
import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.gui.message.Message;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIPopup;

/**
 * バトルリザルト起動パラメータ
 **/
class BattleResultPopupUIParam {
  public var bJustZero:Bool = false;
  public var item:String    = null;
  public var food:Int       = 0;
  public var money:Int      = 0;
  public function new() {}
}

/**
 * バトルリザルト
 **/
class BattleResultPopupUI extends FlxUIPopup {

  // ------------------------------------
  // ■フィールド
  var _owner:SeqMgr;
  var _prm:BattleResultPopupUIParam;

  var _txtItem:FlxUIText;
  var _txtFood:FlxUIText;
  var _txtMoney:FlxUIText;

  /**
   * コンストラクタ
   **/
  public function new(owner:SeqMgr, prm:BattleResultPopupUIParam) {
    super();
    _owner = owner;
    _prm = prm;
  }

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "battle_result";
    super.create();

    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "txtitem":
          _txtItem = cast widget;
          _txtItem.visible = false;
          if(_prm.item != null) {
            _txtItem.visible = true;
            _txtItem.text = _prm.item;
          }
        case "txtfood":
          _txtFood = cast widget;
          _txtFood.text = '${_prm.food}';
        case "txtmoney":
          _txtMoney = cast widget;
          _txtMoney.text = '${_prm.money}';
        default:
      }
    });
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

    PlayState.forceUpdate(elapsed);

    if(Input.press.B) {
      // 閉じる
      close();
    }
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

  /**
   * 画面を閉じる
   **/
  override public function close():Void {

    if(_prm.food > 0) {
      // 食糧を増やす
      _owner.addFood(_prm.food);
    }

    // お金を増やす
    {
      var text = '${_prm.money}G';
      Message.push2(Msg.ITEM_GET, [text]);
      Global.addMoney(_prm.money);
    }

    super.close();
  }


}
