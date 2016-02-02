package jp_2dgames.game;

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
  static inline var CHIP_PLAYER:Int = 9; // プレイヤー

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

  public static function getPlayerPosition():FlxPoint {
    var layer = _tmx.getLayer("object");
    var pt = layer.search(CHIP_PLAYER);
    pt.x = Field.toWorldX(pt.x);
    pt.y = Field.toWorldY(pt.y);
    return pt;
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
