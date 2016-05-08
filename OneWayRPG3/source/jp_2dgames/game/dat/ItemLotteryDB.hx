package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテム獲得の抽選DB
 **/
class ItemLotteryDB {

  public static function lottery(level:Int):ItemsKind {
    var gen = new LotteryGenerator<ItemsKind>();
    for(lot in MyDB.itemlottery.all) {
      if(lot.start <= level && level <= lot.end) {
        gen.add(lot.item.id, lot.ratio);
      }
    }

    return gen.exec();
  }
}
