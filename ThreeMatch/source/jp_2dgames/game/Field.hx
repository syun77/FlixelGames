package jp_2dgames.game;

import jp_2dgames.game.token.Energy;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Panel;
import jp_2dgames.game.token.PanelUtil;
import jp_2dgames.lib.Array2D;

/**
 * フィールド
 **/
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
  public static function checkErase(x:Float, y:Float, enemy:Enemy):Bool {
    var px = toGridX(x);
    var py = toGridY(y);
    return instance._checkErase(px, py, enemy);
  }
  public static function checkFall():Bool {
    return instance._checkFall();
  }
  public static function checkAppear():Bool {
    return instance._checkAppear();
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
      Panel.add(type, i, j, HEIGHT);
    });
  }

  /**
   * 消去チェック
   **/
  function _checkErase(x:Int, y:Int, enemy:Enemy):Bool {
    var b = FieldEraseChecker.start(_layer, x, y);
    if(b == false) {
      // 消えない
      return false;
    }

    // 消去数
    var v:Int = _layer.get(x, y); // 消したパネルの種類
    var cnt:Int = 0;
    var px:Float = 0;
    var py:Float = 0;
    var layer = FieldEraseChecker.get();
    layer.forEach(function(i:Int, j:Int, v:Int) {
      if(v == FieldEraseChecker.ERASE) {
        // 消去する
        var panel = Panel.getFromIdx(i, j);
        px += panel.x;
        py += panel.y;
        panel.kill();
        _layer.set(i, j, 0);
        cnt++;
      }
    });

    switch(v) {
      case PanelUtil.SWORD:
        // 剣ゲージ増加
        Gauge.addPower(cnt);
      case PanelUtil.SHIELD:
        // シールドゲージ増加
        Gauge.addDefense(cnt);
      case PanelUtil.SHOES:
        // 速度ゲージ増加
        Gauge.addSpeed(cnt);
      case PanelUtil.LIFE:
    }

    px /= cnt;
    py /= cnt;
    var tx = enemy.x + enemy.width/2;
    var ty = enemy.y + enemy.height/2;
    Energy.add(px, py, tx, ty, function() {
      // 敵にダメージ
      var val = Std.int(cnt * 10 * Calc.getPower());
      enemy.damage(val);
    });
    for(i in 0...cnt-1) {
      Energy.add(px, py, tx, ty, null);
    }

    return true;
  }

  /**
   * 落下チェック
   **/
  function _checkFall():Bool {

    // 移動したかどうか
    var ret = false;

    for(j in [for(a in 0...HEIGHT) HEIGHT - a - 1]) {
      for(i in 0...WIDTH) {
        var v = _layer.get(i, j);
        if(v == 0) {
          // チェック不要
          continue;
        }

        // 落下可能な位置を見つける
        var y = _getFallY(i, j);
        if(y == j) {
          // 移動不要
          continue;
        }

        // 移動させる
        var panel = Panel.getFromIdx(i, j);
        panel.move(y);
        _layer.set(i, j, 0);
        _layer.set(i, y, v);

        // 移動した
        ret = true;
      }
    }

    return ret;
  }

  /**
   * パネル出現チェック
   **/
  function _checkAppear():Bool {
    var ret = false;
    _layer.forEach(function(i:Int, j:Int, v:Int) {
      if(v != 0) {
        // パネルの空きはない
        return;
      }
      var y = _getFallY(i, j);
      var d = y - j + HEIGHT;
      var type = Panel.randomType();
      Panel.add(type, i, j, d+2);
      _layer.set(i, j, PanelUtil.toIdx(type));

      // 出現させた
      ret = true;
    });
    return ret;
  }

  function _getFallY(i:Int, j:Int):Int {
    var py = j + 1;
    if(_layer.get(i, py) == 0) {
      // 落下可能
      py = _getFallY(i, py);
    }
    else {
      // 落下できない
      py = j;
    }
    return py;
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
