package jp_2dgames.game.global;

import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.dat.ItemLotteryDB;
import jp_2dgames.game.dat.LotteryGenerator;
import jp_2dgames.game.dat.MyDB;

/**
 * アイテム出現の抽選情報
 **/
class ItemLottery {

  static var _instance:ItemLottery = null;
  public static function createInstance(level:Int):Void {
    _instance = new ItemLottery(level);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function exec():ItemData {
    return _instance._exec();
  }
  public static function getLastLottery():ItemData {
    return _instance.lastLottery;
  }
  public static function clearLastLottery():Void {
    return _instance._clearLastLottery();
  }

  // -----------------------------------------------
  // ■フィールド
  var _generator:LotteryGenerator<ItemsKind>;
  var _lastLottery:ItemData;

  public var lastLottery(get, never):ItemData;

  /**
   * コンストラクタ
   **/
  public function new(level:Int) {
    _generator = ItemLotteryDB.createGenerator(level);
    _clearLastLottery();
  }

  /**
   * 最後に拾ったアイテムを消去する
   **/
  function _clearLastLottery():Void {
    _lastLottery = null;
  }

  /**
   * 抽選を行う
   **/
  function _exec():ItemData {
    var itemid = _generator.exec();
    _lastLottery = ItemUtil.add(itemid);
    return _lastLottery;
  }


  // ---------------------------------------------------
  // ■アクセサメソッド
  function get_lastLottery() { return _lastLottery; }
}
