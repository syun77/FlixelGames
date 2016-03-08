package jp_2dgames.game;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flash.display.BitmapData;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド
 **/
class Field {

  // タイルサイズ
  static inline var TILE_WIDTH:Int = 16;
  static inline var TILE_HEIGHT:Int = 16;

  // チップ番号
  static inline var CHIP_WALL:Int   = 1;  // 壁
  static inline var CHIP_FLOOR:Int  = 2;  // 床
  static inline var CHIP_PLAYER:Int = 9;  // プレイヤー
  static inline var CHIP_SPIKE:Int  = 10; // 鉄球
  static inline var CHIP_GATE:Int   = 11; // ゲート
  static inline var CHIP_GOAL:Int   = 12; // ゴール
  static inline var CHIP_FLAG:Int   = 15; // 拠点

  static var _tmx:TmxLoader = null;
  static var _map:FlxTilemap = null;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    FlxG.state.bgColor = 0xff666666;
    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load('assets/data/${name}.tmx');
  }

  /**
   * マップデータ破棄
   **/
  public static function unload():Void {
    _tmx = null;
    _map = null;
  }

  /**
   * フィールドの幅
   **/
  public static function getWidth():Int {
    return _tmx.width * _tmx.tileWidth;
  }
  /**
   * フィールドの高さ
   **/
  public static function getHeight():Int {
    return _tmx.height * _tmx.tileHeight;
  }

  /**
   * 壁タイルの取得
   **/
  public static function createWallTile():FlxTilemap {
    var csv = _tmx.getLayerCsv("object");
    var r = ~/([\d]{2,}|[2-9])/g; // 0と1以外は置き換える
    csv = r.replace(csv, "0");    // 0に置き換える
    _map = new FlxTilemap();
    _map.loadMapFromCSV(csv, FlxGraphic.fromClass(GraphicAuto), 0, 0, AUTO);
    return _map;
  }

  /**
   * マップ情報から移動経路を生成する
   **/
  public static function createPath(map:FlxTilemap):Array<FlxPoint> {
    // 中心へオフセット
    var d = 8;
    var start = getStartPosition().add(d, d);
    var end = getFlagPosition().add(d, d);
    start.y -= 16; // 画面外に出しておく
    // 16x16のマップなので、8x8にする
    start.x /= 2;
    start.y /= 2;
    end.x /= 2;
    end.y /= 2;
    return map.findPath(start, end);
  }

  public static function isPassage(x:Float, y:Float):Bool {
    var i = Std.int(x / 8);
    var j = Std.int(y / 8);
    if(_map.getTile(i, j) == 0) {
      return true;
    }
    return false;
  }

  /**
   * スタート地点を取得する
   **/
  public static function getStartPosition():FlxPoint {
    var layer = _tmx.getLayer("object");
    var pt = layer.searchRandom(CHIP_PLAYER);
    pt.x = Field.toWorldX(pt.x);
    pt.y = Field.toWorldY(pt.y);
    return pt;
  }

  /**
   * ゴール地点を取得する
   **/
  public static function getGoalPosition():FlxPoint {
    var layer = _tmx.getLayer("object");
    var pt = layer.searchRandom(CHIP_GOAL);
    pt.x = Field.toWorldX(pt.x);
    pt.y = Field.toWorldY(pt.y);
    return pt;
  }

  /**
   * 拠点の座標を取得する
   **/
  public static function getFlagPosition():FlxPoint {
    var layer = _tmx.getLayer("object");
    var pt = layer.searchRandom(CHIP_FLAG);
    pt.x = Field.toWorldX(pt.x);
    pt.y = Field.toWorldY(pt.y);
    return pt;
  }

  /**
   * 各種オブジェクトを配置
   **/
  public static function createObjects():Void {
    var layer = _tmx.getLayer("object");
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = toWorldX(i);
      var y = toWorldY(j);
      switch(v) {
        case CHIP_WALL:
      }
    });
  }

  /**
   * グリッド座標をワールド座標に変換(X)
   **/
  public static function toWorldX(i:Float):Float {
    return i * TILE_WIDTH;
  }

  /**
   * グリッド座標をワールド座標に変換(Y)
   **/
  public static function toWorldY(j:Float):Float {
    return j * TILE_HEIGHT;
  }

}
