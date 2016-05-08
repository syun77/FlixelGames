package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * 敵情報
 **/
class MyDBUtil {

  public static function load():Void {
    // cdbファイルの読み込み
    var content = openfl.Assets.getText("source/jp_2dgames/game/dat/MyDB.cdb");
    MyDB.load(content);
  }

}
