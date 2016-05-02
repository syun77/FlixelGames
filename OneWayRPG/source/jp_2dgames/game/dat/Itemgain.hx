package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテム出現テーブル
 **/
class ItemGain {
  public static function get(level:Int):Itemgain {
    for(info in MyDB.itemgain.all) {
      if(level == info.floor) {
        return info;
      }
    }

    throw 'Error: Invalid level = ${level}';
  }

  /**
   * アイテムを抽選する
   **/
  public static function lotItem(level:Int):Int {
    var gen = new LotteryGenerator();

    var info = get(level);
    gen.add(info.item1, info.ratio1);
    gen.add(info.item2, info.ratio2);
    gen.add(info.item3, info.ratio3);
    gen.add(info.item4, info.ratio4);
    gen.add(info.item5, info.ratio5);

    return gen.exec();
  }
}
