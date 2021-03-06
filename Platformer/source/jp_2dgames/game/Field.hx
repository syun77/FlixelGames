package jp_2dgames.game;

import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Spike;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flash.display.BitmapData;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

// オートタイル画像
@:bitmap("assets/data/autotiles.png")
/**
 * フィールド
 **/
class TileGraphic extends BitmapData {}

class Field {

  // タイルサイズ
  static inline var TILE_WIDTH:Int = 16;
  static inline var TILE_HEIGHT:Int = 16;

  // チップ番号
  static inline var CHIP_PLAYER:Int = 9;  // プレイヤー
  static inline var CHIP_SPIKE:Int  = 10; // 鉄球
  static inline var CHIP_GOAL:Int   = 11; // ゴール
  static inline var CHIP_GOAST:Int  = 12; // ゴースト
  static inline var CHIP_BAT:Int    = 13; // コウモリ

  static var _tmx:TmxLoader = null;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    FlxG.state.bgColor = FlxColor.CHARCOAL;
    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load('assets/data/${name}.tmx');
  }

  /**
   * マップデータ破棄
   **/
  public static function unload():Void {
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
  public static function createWallTile():FlxTilemap {
    var csv = _tmx.getLayerCsv("wall");
    var map = new FlxTilemap();
    map.loadMap(csv, TileGraphic, 0, 0, FlxTilemap.AUTO);
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
  public static function createObjects():Void {
    var layer = _tmx.getLayer("object");
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = toWorldX(i);
      var y = toWorldY(j);
      switch(v) {
        case CHIP_SPIKE:
          Spike.add(x, y);
        case CHIP_GOAST:
          Enemy.add(EnemyType.Goast, x, y);
        case CHIP_BAT:
          Enemy.add(EnemyType.Bat, x, y);
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
