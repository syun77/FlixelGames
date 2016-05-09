package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * クラスの初期パラメータ
 **/
class ClassDB {

  public static function get(id:ClassesKind):Classes {
    return MyDB.classes.get(id);
  }

  public static function getItems(id:ClassesKind):Array<ItemsKind> {
    // ArrayRead は Array と同等なのでcastできる
    return cast get(id).items;
  }
}
