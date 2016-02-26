package jp_2dgames.game;

import jp_2dgames.game.token.Enemy;
import jp_2dgames.lib.Array2D;
import jp_2dgames.game.token.Wall;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド
 **/
class Field {

  // タイルサイズ
  static inline var TILE_WIDTH:Int = 32;
  static inline var TILE_HEIGHT:Int = 32;

  // チップ番号
  static inline var CHIP_WALL:Int   = 1;  // 壁
  static inline var CHIP_FLOOR:Int  = 2;  // 床
  static inline var CHIP_ENEMY:Int  = 9;  // 敵

  static inline var CHIP_PLAYER:Int = 9;  // プレイヤー
  static inline var CHIP_SPIKE:Int  = 10; // 鉄球
  static inline var CHIP_GATE:Int   = 11; // ゲート
  static inline var CHIP_GOAL:Int   = 12; // ゴール
  static inline var CHIP_LOCK:Int   = 13; // カギで開くブロック
  static inline var CHIP_KEY:Int    = 14; // カギ

  static var _tmx:TmxLoader = null;
  static var _layer:Array2D = null;
  static var _yofs:Float = 0;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    FlxG.state.bgColor = 0xff666666;
    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load('assets/data/${name}.tmx');

    // 壁との衝突チェック用レイヤーの作成
    var w = Std.int(FlxG.width / TILE_WIDTH);
    var h = Std.int(FlxG.height / TILE_HEIGHT+2);
    _layer = new Array2D(w, h);
  }

  /**
   * マップデータ破棄
   **/
  public static function unload():Void {
    _layer = null;
    _tmx = null;
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
  public static function createWallTiles():FlxTilemap {
    var csv = _tmx.getLayerCsv("object");
    var r = ~/([\d]{2,}|[2-9])/g; // 0と1以外は置き換える
    csv = r.replace(csv, "0");    // 0に置き換える
    var map = new FlxTilemap();
    map.loadMap(csv, AssetPaths.IMAGE_AUTOTILES, 0, 0, FlxTilemap.AUTO);
    return map;
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
   * 各種オブジェクトを配置
   **/
  public static function createObjects(yoffset:Float):Void {

    // 敵の種類
    var enemyType = Enemy.randomType();
    enemyType = EnemyType.Horizontal;

    var layer = _tmx.getLayer("object");
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = toWorldX(i);
      var y = toWorldY(j) - getHeight();
      y += yoffset; // スクロールオフセット
      switch(v) {
        case CHIP_WALL:
          Wall.add(x, y);
        case CHIP_ENEMY:
          Enemy.add(enemyType, x, y);
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

  /**
   * ワールド座標をグリッド座標に変換(X)
   **/
  public static function toGridX(x:Float):Int {
    return Std.int(x / TILE_WIDTH);
  }

  /**
   * ワールド座標をグリッド座標に変換(Y)
   **/
  public static function toGridY(y:Float):Int {
    return Std.int(y / TILE_HEIGHT);
  }

  /**
   * 当たり判定用レイヤーの更新
   **/
  public static function updateLayer(yofs:Float):Void {
    _layer.fill(0);
    Wall.forEachAlive(function(wall:Wall) {
      var i = toGridX(wall.x);
      var j = toGridY(wall.y-yofs);
      _layer.set(i, j, 1);
    });

    _yofs = yofs;
  }

  /**
   * 指定の座標で衝突するかどうか
   **/
  public static function isHit(x1:Float, y1:Float, x2:Float, y2:Float):Bool {

    var i1 = toGridX(x1);
    var j1 = toGridY(y1 - _yofs);
    var i2 = toGridX(x2);
    var j2 = toGridY(y2 - _yofs);

    return _layer.checkBresenhamLine(1, i1, j1, i2, j2);
  }
}
