package jp_2dgames.game;

import jp_2dgames.game.token.Switch;
import jp_2dgames.game.token.Block.BlockType;
import jp_2dgames.game.token.Item;
import jp_2dgames.game.token.Block;
import jp_2dgames.game.token.Gate;
import jp_2dgames.game.token.Spike;
import jp_2dgames.game.token.Floor;
import flixel.FlxG;
import flixel.util.FlxPoint;
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
  static inline var CHIP_LOCK:Int   = 13; // カギで開くブロック
  static inline var CHIP_KEY:Int    = 14; // カギ
  static inline var CHIP_BLOCK_RED:Int     = 25; // ブロック(赤)
  static inline var CHIP_BLOCK_GREEN:Int   = 26; // ブロック(緑)
  static inline var CHIP_BLOCK_BLUE:Int    = 27; // ブロック(青)
  static inline var CHIP_BLOCK_YELLOW:Int  = 28; // ブロック(黄)
  static inline var CHIP_SWITCH_RED:Int    = 33; // スイッチ(赤)
  static inline var CHIP_SWITCH_GREEN:Int  = 34; // スイッチ(緑)
  static inline var CHIP_SWITCH_BLUE:Int   = 35; // スイッチ(青)
  static inline var CHIP_SWITCH_YELLOW:Int = 36; // スイッチ(黄)

  static var _tmx:TmxLoader = null;

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
  public static function createObjects():Void {
    var layer = _tmx.getLayer("object");
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = toWorldX(i);
      var y = toWorldY(j);
      switch(v) {
        case CHIP_WALL:
        case CHIP_FLOOR:
          Floor.add(x, y);
        case CHIP_SPIKE:
          Spike.add(x, y);
        case CHIP_GATE:
          Gate.add(x, y);
        case CHIP_LOCK:
          Block.add(BlockType.Lock, x, y);
        case CHIP_BLOCK_RED:
          Block.add(BlockType.Red, x, y);
        case CHIP_BLOCK_GREEN:
          Block.add(BlockType.Green, x, y);
        case CHIP_BLOCK_BLUE:
          Block.add(BlockType.Blue, x, y);
        case CHIP_BLOCK_YELLOW:
          Block.add(BlockType.Yellow, x, y);
        case CHIP_SWITCH_RED:
          Switch.add(SwitchType.Red, x, y);
        case CHIP_SWITCH_GREEN:
          Switch.add(SwitchType.Green, x, y);
        case CHIP_SWITCH_BLUE:
          Switch.add(SwitchType.Blue, x, y);
        case CHIP_SWITCH_YELLOW:
          Switch.add(SwitchType.Yellow, x, y);
        case CHIP_KEY:
          Item.add(x, y);
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
