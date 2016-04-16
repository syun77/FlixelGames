package jp_2dgames.game;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.game.token.Token;

/**
 * ユーティリティ
 **/
class Util {

  /**
   * ノックバック方向を取得する
   **/
  public static function getKnockBackDirection(t1:Token, t2:Token):Dir {
    var dx = t1.xcenter - t2.xcenter;
    var dy = t1.ycenter - t2.ycenter;
    if(Math.abs(dx) > Math.abs(dy)) {
      if(dx < 0) {
        return Dir.Left;
      }
      else {
        return Dir.Right;
      }
    }
    else {
      if(dy < 0) {
        return Dir.Up;
      }
      else {
        return Dir.Down;
      }
    }
  }
}
