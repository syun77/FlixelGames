package jp_2dgames.game.dat;

import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.ResistData;
import jp_2dgames.game.dat.MyDB;

/**
 * 敵DB
 **/
class EnemyDB {

  public static function get(id:EnemiesKind):Enemies {
    return MyDB.enemies.get(id);
  }

  public static function getName(id:EnemiesKind):String {
    return get(id).name;
  }

  public static function getImage(id:EnemiesKind):String {
    var image = get(id).image;
    return StringTools.replace(image, "../../../../", "");
  }

  public static function getHp(id:EnemiesKind):Int {
    return get(id).hp;
  }

  public static function getAtk(id:EnemiesKind):Int {
    return get(id).atk;
  }

  public static function getHit(id:EnemiesKind):Int {
    return Std.int(get(id).hit * 100);
  }

  public static function lotteryDropItem(id:EnemiesKind):ItemsKind {
    var drops = get(id).drops;
    if(drops.length < 1) {
      // ドロップアイテムなし
      return ItemsKind.None;
    }

    var gen = new LotteryGenerator<ItemsKind>();
    for(drop in drops) {
      gen.add(drop.item.id, drop.ratio);
    }

    return gen.exec();
  }

  /**
   * 耐性情報の取得
   **/
  public static function getResists(id:EnemiesKind):ResistList {
    var ret = new ResistList();
    var resists = get(id).resists;
    for(resist in resists) {
      var attr = AttributeUtil.fromKind(resist.attr.id);
      var resistance = ResistUtil.fromKind(resist.resist.id);
      var data = new ResistData(attr, resistance, resist.value);
      ret.add(data);
    }

    return ret;
  }
}
