package jp_2dgames.game;

import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.DropItem;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.lib.Array2D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.FlxSprite;
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

  // グリッドサイズ
  public static inline var GRID_SIZE:Int = 32;

  // データパスのルート
  public static inline var PATH_ROOT:String = "assets/data/levels/";
  public static inline var PATH_TILESET:String = '${PATH_ROOT}tileset.png';
  public static inline var PATH_TILENONE:String = '${PATH_ROOT}tilenone.png';
  public static inline var IMAGE_AUTOTILES:String = AssetPaths.IMAGE_AUTOTILES;
//  public static inline var IMAGE_AUTOTILES:String = null;

  // マップ内に複数存在するものをランダムで抽選するかどうか
  static inline var RANDOM_START:Bool = false; // スタート地点
  static inline var RANDOM_GOAL:Bool  = false; // ゴール地点

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

  // タイルサイズ
  static inline var TILE_WIDTH:Int = 32;
  static inline var TILE_HEIGHT:Int = 32;

  // チップ番号
  static inline var CHIP_NONE:Int   = 0;  // 何もなし
  static inline var CHIP_WALL:Int   = 1;  // 壁
  static inline var CHIP_FLOOR:Int  = 2;  // 床
  static inline var CHIP_TREE:Int   = 3;  // 木
  static inline var CHIP_ORB_START:Int = 9; // オーブ(開始)
  static inline var CHIP_ORB_END:Int = 12; // オーブ(終端)
  static inline var CHIP_ENEMY_START:Int = 17; // 敵(開始)
  static inline var CHIP_ENEMY_END:Int = 25; // 敵(終端)

  static inline var CHIP_PLAYER:Int = 9;  // プレイヤー
  public static inline var CHIP_STAIR:Int  = 10; // 階段
  static inline var CHIP_ENEMY:Int  = 11; // 敵
  static inline var CHIP_ITEM:Int   = 12; // アイテム
  static inline var CHIP_HEART:Int  = 13; // ハート
  static inline var CHIP_FLAG:Int = 15;
  static inline var CHIP_GOAL:Int = 16;

  // コリジョンにするチップ
  static var COLLISION_CHIPS:Array<Int> = [
    CHIP_TREE
  ];

  static var _tmx:TmxLoader = null;
  static var _map:FlxTilemap = null;
  static var _layer:Array2D = null;
  static var _sprBack:FlxSprite = null;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

//    FlxG.state.bgColor = 0xff666666;
    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load(PATH_ROOT + '${name}.tmx');
    _layer = _tmx.getLayer(LAYER_NAME);

    // スタート地点を作成
    if(RANDOM_START)
    {
      var pt = getStartPosition();
      _layer.clearAll(CHIP_PLAYER);
      _layer.set(Std.int(pt.x), Std.int(pt.y), CHIP_PLAYER);
      pt.put();
    }
    // ゴール地点を作成
    if(RANDOM_GOAL)
    {
      var pt = getGoalPosition();
      _layer.clearAll(CHIP_STAIR);
      _layer.set(Std.int(pt.x), Std.int(pt.y), CHIP_STAIR);
      pt.put();
    }
  }

  /**
   * マップデータ破棄
   **/
  public static function unload():Void {
    _tmx = null;
    _map = null;
    _sprBack = null;
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
   * マップレイヤーを取得
   **/
  public static function getLayer(name:String=null):Array2D {
    if(name == null) {
      name = LAYER_NAME;
    }
    return _tmx.getLayer(name);
  }

  /**
   * マップレイヤーを設定
   **/
  public static function setLayer(layer:Array2D):Void {
    _layer = layer;
  }

  /**
   * 壁タイルの取得
   **/
  public static function createWallTile():FlxTilemap {
    var csv = _tmx.getLayerCsv(LAYER_NAME);
    if(true) {
      // 指定の値を壁にする
      for(v in COLLISION_CHIPS) {
        var r = new EReg('${v},', "g");
        csv = r.replace(csv, "1,");
      }
    }
    // 1のみ壁にする
    var r = ~/([\d]{2,}|[2-9])/g; // 0と1以外は置き換える
    csv = r.replace(csv, "0");    // 0に置き換える
    _map = new FlxTilemap();
    if(IMAGE_AUTOTILES != null) {
      _map.loadMapFromCSV(csv, IMAGE_AUTOTILES, 0, 0, AUTO);
    }
    else {
      _map.loadMapFromCSV(csv, FlxGraphic.fromClass(GraphicAuto), 0, 0, AUTO);
    }
    return _map;
  }

  /**
   * 背景画像を作成する
   **/
  public static function createBackground(layer:Array2D, spr:FlxSprite):FlxSprite {

    var w = layer.width * GRID_SIZE;
    var h = layer.height * GRID_SIZE;
    // チップ画像読み込み
    var chip = FlxG.bitmap.add(PATH_TILESET);
    var none = FlxG.bitmap.add(PATH_TILENONE);
    // 透明なスプライトを作成
    var col = FlxColor.TRANSPARENT;
    spr.makeGraphic(w, h, col);
    spr.pixels.fillRect(new Rectangle(0, 0, w, h), col);
    // 転送先の座標
    var pt = new Point();
    // 転送領域の作成
    var rect = new Rectangle(0, 0, GRID_SIZE, GRID_SIZE);
    // 描画関数
    var func = function(i:Int, j:Int, v:Int) {

      if(v >= CHIP_ORB_START) {
        // オーブ以降は描画しない
        v = CHIP_NONE;
      }

      pt.x = i * GRID_SIZE;
      pt.y = j * GRID_SIZE;

      // 床チップ描画
      {
        rect.left   = 0;
        rect.right  = rect.left + GRID_SIZE;
        rect.top    = 0;
        rect.bottom = rect.top + GRID_SIZE;
        spr.pixels.copyPixels(none.bitmap, rect, pt, false);
      }

      rect.left   = ((v - 1) % 8) * GRID_SIZE;
      rect.right  = rect.left + GRID_SIZE;
      rect.top    = Std.int((v - 1) / 8) * GRID_SIZE;
      rect.bottom = rect.top + GRID_SIZE;

      // 床チップ描画
      switch(v) {
        case CHIP_NONE, CHIP_WALL, CHIP_STAIR, CHIP_TREE:
          // チップを描画する
          spr.pixels.copyPixels(chip.bitmap, rect, pt, true);
      }
    }

    // レイヤーを走査する
    layer.forEach(func);
    spr.dirty = true;
    spr.updateFramePixels();

    // メンバ変数に保存
    _sprBack = spr;

    return spr;
  }

  /**
   * 踏んでいるチップを取得する
   **/
  public static function getChip(xc:Int, yc:Int):Int {
    var layer = getLayer();
    return layer.get(xc, yc);
  }

  /**
   * マップ情報から移動経路を生成する
   **/
  public static function createPath(map:FlxTilemap):Array<FlxPoint> {
    // 中心へオフセット
    var d = 8;
    var start = getStartPosition().add(d, d);
    var end = getFlagPosition().add(d, d);
    start.x -= 16; // 画面外に出しておく
    // 16x16のマップなので、8x8にする
    start.x /= 2;
    start.y /= 2;
    end.x /= 2;
    end.y /= 2;
    return map.findPath(start, end);
  }

  /**
   * 壁かどうか
   **/
  public static function isCollide(x:Int, y:Int):Bool {
    var i = Std.int(x);
    var j = Std.int(y);
    var layer = getLayer();
    if(layer.get(i, j) == CHIP_WALL) {
      // 壁
      return true;
    }

    return false;
  }

  /**
   * スタート地点を取得する
   **/
  public static function getStartPosition():FlxPoint {
    var layer = _tmx.getLayer(LAYER_NAME);
    var pt = layer.searchRandom(CHIP_PLAYER);
//    pt.x = Field.toWorldX(pt.x);
//    pt.y = Field.toWorldY(pt.y);
    return pt;
  }

  /**
   * ゴール地点を取得する
   **/
  public static function getGoalPosition():FlxPoint {
    var layer = _tmx.getLayer(LAYER_NAME);
    var pt = layer.searchRandom(CHIP_STAIR);
//    pt.x = Field.toWorldX(pt.x);
//    pt.y = Field.toWorldY(pt.y);
    return pt;
  }

  /**
   * 拠点の座標を取得する
   **/
  public static function getFlagPosition():FlxPoint {
    var layer = _tmx.getLayer(LAYER_NAME);
    var pt = layer.searchRandom(CHIP_FLAG);
    pt.x = Field.toWorldX(pt.x);
    pt.y = Field.toWorldY(pt.y);
    return pt;
  }

  /**
   * 各種オブジェクトを配置
   **/
  public static function createObjects():Void {
    var layer = _tmx.getLayer(LAYER_NAME);
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = toWorldX(i);
      var y = toWorldY(j);
      switch(v) {
        case CHIP_WALL:
        default:
          if(CHIP_ORB_START <= v && v <= CHIP_ORB_END) {
            var itemid = v - CHIP_ORB_START;
            if(Global.hasOrb(itemid) == false) {
              // まだ見つけていない場合のみ配置
              DropItem.add(itemid, x, y);
            }
          }
          else if(CHIP_ENEMY_START <= v && v <= CHIP_ENEMY_END) {
            var eid = v - CHIP_ENEMY_START + 1;
            Enemy.add(eid, x, y, 0, 0);
          }
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

