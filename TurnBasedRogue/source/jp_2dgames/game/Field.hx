package jp_2dgames.game;

import jp_2dgames.game.global.Global;
import jp_2dgames.game.token.Heart;
import jp_2dgames.game.item.ItemType;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.actor.Params;
import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.game.actor.Enemy;
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

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

  // タイルサイズ
  static inline var TILE_WIDTH:Int = 32;
  static inline var TILE_HEIGHT:Int = 32;

  // チップ番号
  static inline var CHIP_NONE:Int   = 0;  // 何もなし
  static inline var CHIP_WALL:Int   = 1;  // 壁
  static inline var CHIP_FLOOR:Int  = 2;  // 床
  static inline var CHIP_PLAYER:Int = 9;  // プレイヤー
  public static inline var CHIP_STAIR:Int  = 10; // 階段
  static inline var CHIP_ENEMY:Int  = 11; // 敵
  static inline var CHIP_ITEM:Int   = 12; // アイテム
  static inline var CHIP_HEART:Int  = 13; // ハート

  static inline var CHIP_FLAG:Int = 15;
  static inline var CHIP_GOAL:Int = 16;

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
    _tmx.load('assets/data/${name}.tmx');
    _layer = _tmx.getLayer(LAYER_NAME);

    // スタート地点を作成
    {
      var pt = getStartPosition();
      _layer.clearAll(CHIP_PLAYER);
      _layer.set(Std.int(pt.x), Std.int(pt.y), CHIP_PLAYER);
      pt.put();
    }
    // ゴール地点を作成
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
    var r = ~/([\d]{2,}|[2-9])/g; // 0と1以外は置き換える
    csv = r.replace(csv, "0");    // 0に置き換える
    _map = new FlxTilemap();
    _map.loadMapFromCSV(csv, FlxGraphic.fromClass(GraphicAuto), 0, 0, AUTO);
    return _map;
  }

  /**
	 * 背景画像を作成する
	 **/
  public static function createBackground(layer:Array2D, spr:FlxSprite):FlxSprite {
    var w = layer.width * GRID_SIZE;
    var h = layer.height * GRID_SIZE;
    // チップ画像読み込み
    var chip = FlxG.bitmap.add("assets/data/tileset.png");
    var none = FlxG.bitmap.add("assets/data/tilenone.png");
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
        case CHIP_NONE, CHIP_WALL, CHIP_STAIR:
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
    var prm = new Params();
    var layer = _tmx.getLayer(LAYER_NAME);
    layer.forEach(function(i:Int, j:Int, v:Int) {
      var x = toWorldX(i);
      var y = toWorldY(j);
      switch(v) {
        case CHIP_WALL:
        case CHIP_ENEMY:
          prm.id = _getEnemyID();
          Enemy.add(i, j, Dir.Down, prm);
        case CHIP_ITEM:
          var itemid = FlxG.random.int(0, ItemType.MAX-1);
          DropItem.add(i, j, itemid);
        case CHIP_HEART:
          Heart.add(i, j);
      }
    });
  }

  static function _getEnemyID():Int {
    var arr:Array<Int> = null;
    switch(Global.level) {
      case 1:
        arr = [1];
      case 2:
        arr = [1, 2];
      case 3:
        arr = [1, 3];
      case 4:
        arr = [1, 2];
      case 5:
        arr = [2, 5];
      case 6:
        arr = [1];
      case 7:
        arr = [1, 2, 3];
      case 8:
        arr = [4];
      case 9:
        arr = [2, 5];
      case 10:
        arr = [1, 4];
      default:
        arr = [1];
    }

    var rnd = FlxG.random.int(0, arr.length-1);
    return arr[rnd];
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
   * テレポート可能な位置を探す
   **/
  public static function teleport(xc:Int, yc:Int):FlxPoint {

    var layer = getLayer();
    var w = _layer.width / 2;
    var h = _layer.height / 2;
    var distance = w*w + h*h;
    var cnt = 1000; // 試行回数
    for(i in 0...cnt) {
      var pt:FlxPoint = null;
      pt = layer.searchRandom(Field.CHIP_NONE);
      if(pt == null) {
        // そもそも移動できない
        break;
      }

      var px = Std.int(pt.x);
      var py = Std.int(pt.y);
      var dx = px - xc;
      var dy = py - yc;
      if(dx*dx + dy*dy < distance) {
        // もっと遠くの場所を探す
        // 条件となる距離を近くする
        distance--;
        continue;
      }

      if(Enemy.getFromPosition(px, py) == null) {
        // ワープ可能
        return pt;
      }
      pt.put();
    }

    // 見つからなかった
    return FlxPoint.get(xc, yc);
  }
}

