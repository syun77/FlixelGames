package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 敵出現テーブル
 **/
class EnemyEncountDB {

  public static function lottery(level:Int):EnemiesKind {
    var gen = new LotteryGenerator<EnemiesKind>();
    for(lot in MyDB.enemyencount.all) {
      if(lot.start <= level && level <= lot.end) {
        gen.add(lot.enemy.id, lot.ratio);
      }
    }

    return gen.exec();
  }
}
