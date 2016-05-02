package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 敵出現テーブル
 **/
class EnemyEncount {
  public static function get(level:Int):Enemyencount {
    for(info in MyDB.enemyencount.all) {
      if(level == info.floor) {
        return info;
      }
    }

    throw 'Error: Invalid level = ${level}';
  }

  /**
   * 出現する敵の抽選
   **/
  public static function lotEnemy(level:Int):Int {
    var gen = new LotteryGenerator();

    var info = get(level);
    gen.add(info.eid1, info.ratio1);
    gen.add(info.eid2, info.ratio2);
    gen.add(info.eid3, info.ratio3);

    return gen.exec();
  }
}
