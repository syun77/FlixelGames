package jp_2dgames.game;
import jp_2dgames.game.token.Infantry;

/**
 * コスト
 **/
class Cost {
  // 砲台製造コスト
  public static var infantry(get, never):Int;

  static function get_infantry() {
    var count = Infantry.parent.countLiving();
    if(count < 0) {
      count = 0;
    }
    return 5 + count * 3;
  }
}
