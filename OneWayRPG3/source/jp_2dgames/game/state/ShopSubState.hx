package jp_2dgames.game.state;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.dat.ItemDB;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.dat.ItemLotteryDB;
import jp_2dgames.game.state.InventorySubState.InventoryMode;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;

/**
 * ショップSubState
 **/
class ShopSubState extends InventorySubState {

  // -----------------------------------------------
  // ■フィールド
  var _list:Array<ItemData>;

  /**
   * コンストラクタ
   **/
  public function new(owner:SeqMgr) {
    super(owner, InventoryMode.ShopBuy);

    // ショップアイテム生成
    _list = new Array<ItemData>();
    var gen = ItemLotteryDB.createGenerator(Global.level);
    for(i in 0...ItemList.MAX) {
      var id = gen.exec();
      var item = ItemUtil.add(id);
      _list.push(item);
    }
  }

  /**
   * 表示項目の更新
   **/
  override function _updateItems():Void {
    super._updateItems();
  }

  override function _getItemLabel(item:ItemData):String {
    return ItemUtil.getName3(item);
  }

  override function _isItemLockFromIdx(idx:Int):Bool {
    var item = _getItemFromIdx(idx);
    var cost = ItemDB.getBuy(item.id);
    if(cost > Global.money) {
      // お金が足りない
      return true;
    }
    return false;
  }

  /**
   * ボタンクリックのコールバック
   **/
  override function _cbClick(name:String):Void {
    if(name == "cancel") {
      // キャンセルを押したら閉じる
      close();
      return;
    }

    if(ItemList.isFull()) {
      // 購入できない
      Message.push2(Msg.ITEM_CANT_BUY);
      return;
    }

    // 購入
    var idx = Std.parseInt(name);
    var item = _list[idx];
    var cost = ItemDB.getBuy(item.id);
    var itemname = ItemUtil.getName(item);
    // お金消費
    Global.subMoney(cost);
    ItemList.push(item);
    Message.push2(Msg.ITEM_BUY, [itemname, cost]);
    // リストから削除
    _list.remove(item);

    if(_list.length == 0) {
      // 閉じる
      close();
    }
    else {
      // 表示項目を更新
      _updateItems();
    }
  }

  /**
   * アイテムの取得
   **/
  override function _getItemFromIdx(idx:Int):ItemData {
    return _list[idx];
  }

  /**
   * アイテムの最大数
   **/
  override function _getItemMax():Int {
    return ItemList.MAX;
  }
}
