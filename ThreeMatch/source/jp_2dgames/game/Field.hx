package jp_2dgames.game;

/**
 * フィールド
 **/
import jp_2dgames.game.token.Panel;
import jp_2dgames.game.token.PanelUtil;
import jp_2dgames.lib.Array2D;
class Field {

  public static inline var GRID_SIZE:Int = 16;
  public static inline var WIDTH:Int = 8;
  public static inline var HEIGHT:Int = 8;
  public static inline var GRID_WIDTH:Int = GRID_SIZE * WIDTH;
  public static inline var GRID_HEIGHT:Int = GRID_SIZE * HEIGHT;

  public static var xofs(get, never):Int;
  public static var yofs(get, never):Int;

  public static var instance:Field = null;

  public static function toWorldX(i:Int):Float {
    return xofs + i * GRID_SIZE;
  }
  public static function toWorldY(j:Int):Float {
    return yofs + j * GRID_SIZE;
  }
  public static function toGridX(x:Float):Int {
    return Std.int((x - xofs) / GRID_SIZE);
  }
  public static function toGridY(y:Float):Int {
    return Std.int((y - yofs) / GRID_SIZE);
  }
  public static function create():Void {
    instance = new Field();
    FieldEraseChecker.create();
  }
  public static function destroy():Void {
    FieldEraseChecker.destroy();
    instance = null;
  }
  public static function random():Void {
    instance._random();
  }
  public static function fromWorld():Void {
    instance._fromWorld();
  }
  public static function toWorld():Void {
    instance._toWorld();
  }
  public static function checkErase(x:Float, y:Float):Void {
    var px = toGridX(x);
    var py = toGridY(y);
    instance._checkErase(px, py);
  }

  // --------------------------------------------------------------------
  // ■フィールド
  var _layer:Array2D;

  /**
   * コンストラクタ
   **/
  public function new() {
    _layer = new Array2D(WIDTH, HEIGHT);
  }

  function _random():Void {
    _layer.forEach(function(i:Int, j:Int, v:Int) {
      var val = PanelUtil.random();
      _layer.set(i, j, val);
    });
  }

  function _fromWorld():Void {
    _layer.fill(0);
    Panel.parent.forEach(function(panel:Panel) {
      var i = toGridX(panel.x);
      var j = toGridY(panel.y);
      var idx = PanelUtil.toIdx(panel.type);
      _layer.set(i, j, idx);
    });
  }

  function _toWorld():Void {
    Panel.killAll();
    _layer.forEach(function(i:Int, j:Int, v:Int) {
      var type = PanelUtil.toType(v);
      Panel.add(type, i, j);
    });
  }

  /**
   * 消去チェック
   **/
  function _checkErase(x:Int, y:Int):Bool {
    var b = FieldEraseChecker.start(_layer, x, y);
    if(b == false) {
      // 消えない
      return false;
    }
    var layer = FieldEraseChecker.get();
    layer.forEach(function(i:Int, j:Int, v:Int) {
      if(v == FieldEraseChecker.ERASE) {
        // 消去する
        var panel = Panel.getFromIdx(i, j);
        panel.alpha = 0.5;
      }
    });

    return true;
  }

  // --------------------------------------------------------------------
  // ■アクセサ
  static function get_xofs() {
    return GRID_SIZE;
  }
  static function get_yofs() {
    return GRID_SIZE;
  }

}
