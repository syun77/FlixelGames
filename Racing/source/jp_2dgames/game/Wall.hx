package jp_2dgames.game;

import jp_2dgames.game.token.Player;
import flixel.util.FlxRandom;

/**
 * 壁
 **/
class Wall {

  static inline var LEFT = 44;
  static inline var RIGHT = 192;

  /**
   * 道路に収まるようにクリッピングする
   **/
  public static function clip(spr:Player):Bool {

    var ret = false;

    if(LEFT > spr.left) {
      // 左カベに衝突
      spr.x = LEFT;
      ret = true;
    }
    if(RIGHT < spr.right) {
      // 右カベに衝突
      spr.x = RIGHT - spr.width;
      ret = true;
    }

    return ret;
  }

  public static function randomX():Float {
    return FlxRandom.intRanged(LEFT, RIGHT-32);
  }
}
