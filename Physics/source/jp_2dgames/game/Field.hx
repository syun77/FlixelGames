package jp_2dgames.game;
import jp_2dgames.game.token.Ball;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド情報
 **/
class Field {
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
      if(v < 1 || 8 < v) {
        return;
      }
      var number = v - 1;
      var px = i * 16;
      var py = j * 16;
      var ball = Ball.add(number, px, py);

      if(number == 0) {
        // プレイヤーとなるボール
        player = ball;
      }
    });

    return player;
  }
}
