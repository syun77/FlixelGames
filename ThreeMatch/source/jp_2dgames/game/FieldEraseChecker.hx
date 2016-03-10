package jp_2dgames.game;

import jp_2dgames.game.token.PanelUtil;
import jp_2dgames.lib.Array2D;
/**
 * 消去判定用
 **/
class FieldEraseChecker {

  public static inline var NONE:Int = 0;
  public static inline var DONE:Int = 1; // チェック済み
  public static inline var ERASE:Int = 2; // 消去可能

  static var _layer:Array2D; // 消去判定用レイヤー

  public static function create():Void {
    _layer = new Array2D(Field.WIDTH, Field.HEIGHT);
  }
  public static function destroy():Void {
    _layer = null;
  }
  public static function get():Array2D {
    return _layer;
  }

  public static function start(layer:Array2D, x:Int, y:Int):Bool {
    _layer.fill(NONE);
    var v = layer.get(x, y);
    if(v == 0 || v == PanelUtil.SKULL) {
      // 判定不要
      return false;
    }
    // 判定済み
    _layer.set(x, y, ERASE);

    // チェック開始
    _recursive(v, layer, x, y);

    return true;
  }

  static function _recursive(v:Int, layer:Array2D, x:Int, y:Int):Void {
    var xTbl = [-1, 0, 1, 0];
    var yTbl = [0, -1, 0, 1];
    for(idx in 0...4) {
      var dx = xTbl[idx];
      var dy = yTbl[idx];
      var x2 = x + dx;
      var y2 = y + dy;
      if(_layer.get(x2, y2) != NONE) {
        // チェック済み
        continue;
      }

      var v2 = layer.get(x2, y2);
      if(v == v2) {
        // 同一色なので消去可能
        _layer.set(x2, y2, ERASE);
      }
      else {
        // 同一色でない
        if(v2 == PanelUtil.SKULL) {
          // ドクロは巻き込んで消える
          _layer.set(x2, y2, ERASE);
        }
        else {
          _layer.set(x2, y2, DONE);
        }
        continue;
      }
      _recursive(v, layer, x+dx, y+dy);
    }
  }
}
