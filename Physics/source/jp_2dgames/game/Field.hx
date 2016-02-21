package jp_2dgames.game;
import jp_2dgames.game.token.Hole;
import jp_2dgames.game.token.Ball;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド情報
 **/
class Field {

  static inline var CHIP_PLAYER = 1;
  static inline var CHIP_BALL_BEGIN = 1;
  static inline var CHIP_BALL_END = 9;
  static inline var CHIP_HOLE = 17;

  static var _map:TmxLoader;

  public static function load(level:Int):Void {
    var name = TextUtil.fillZero(level, 3);
    _map = new TmxLoader();
    _map.load('assets/data/${name}.tmx');
  }
  public static function unload():Void {
    _map = null;
  }
  public static function createObjects():Ball {
    var player:Ball = null;
    var layer = _map.getLayer("objects");
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var px = i * 16;
      var py = j * 16;
      if(CHIP_BALL_BEGIN <= v && v < CHIP_BALL_END ) {
        var number = v - 1;
        var ball = Ball.add(number, px, py);

        if(number == 0) {
          // プレイヤーとなるボール
          player = ball;
        }
      }
      else {
        switch(v) {
          case CHIP_HOLE:
            Hole.add(px, py);
        }
      }
    });

    return player;
  }
}
