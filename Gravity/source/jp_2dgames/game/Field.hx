package jp_2dgames.game;

import jp_2dgames.game.token.Hook;
import jp_2dgames.game.token.Spike;
import jp_2dgames.lib.DirUtil.Dir;
import flixel.math.FlxPoint;
import flash.geom.Point;
import flixel.util.FlxColor;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import jp_2dgames.lib.Array2D;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.lib.TmxLoader;

/**
 * フィールド
 **/
class Field {

  // スタート地点・ゴール地点をランダムにする
  public static inline var RANDOM_START_GOAL:Bool = false;

  // グリッドサイズ
  public static inline var GRID_SIZE:Int = 16;

  // 座標をワールド座標で返す
  public static inline var POSITION_TO_WORLD:Bool = true;

  // オブジェクトレイヤー
  static inline var LAYER_NAME:String = "object";

  // タイルサイズ
  static inline var TILE_WIDTH:Int  = GRID_SIZE;
  static inline var TILE_HEIGHT:Int = GRID_SIZE;

  // チップ番号
  static inline var CHIP_NONE:Int   = 0;  // 何もなし
  static inline var CHIP_WALL:Int   = 1;  // 壁
  static inline var CHIP_FLOOR:Int  = 2;  // 床
  static inline var CHIP_FLOOR2:Int = 3;  // 落下床
  static inline var CHIP_PLAYER:Int = 9;  // プレイヤー
  static inline var CHIP_SPIKE:Int  = 10; // トゲ
  static inline var CHIP_ENEMY:Int  = 11; // 敵
  static inline var CHIP_GOAL:Int   = 12; // ゴール
  static inline var CHIP_BLOCK:Int  = 15; // 隠しブロック
  static inline var CHIP_TRIGGER_SPIKE_DOWN:Int = 16; // 停止しているトゲを落とす
  static inline var CHIP_HOOK:Int   = 17; // ロープを引っかけるフック
  static inline var CHIP_SPIKE_UP:Int    = 29; // トゲ(上に移動)
  static inline var CHIP_SPIKE_DOWN:Int  = 30; // トゲ(下に移動)
  static inline var CHIP_SPIKE_LEFT:Int  = 31; // トゲ(左に移動)
  static inline var CHIP_SPIKE_RIGHT:Int = 32; // トゲ(右に移動)

  static inline var CHIP_PIT:Int         = 17; // トゲ穴
  static inline var CHIP_PIT_LEFT:Int    = 18; // トゲ穴(左側に出現)
  static inline var CHIP_PIT_RIGHT:Int   = 19; // トゲ穴(右側に出現)
  static inline var CHIP_PIT_DOWN:Int    = 20; // トゲ穴(下側に出現)

  static inline var CHIP_FLAG:Int = 15;
  static inline var CHIP_STAIR:Int = 17;

  static var _tmx:TmxLoader = null;
  static var _map:FlxTilemap = null;
  static var _layer:Array2D = null;
  static var _sprBack:FlxSprite = null;

  /**
   * マップデータ読み込み
   **/
  public static function loadLevel(level:Int):Void {

    FlxG.state.bgColor = 0xFF333333;//0xff666666;
    var name = TextUtil.fillZero(level, 3);
    _tmx = new TmxLoader();
    _tmx.load('assets/data/${name}.tmx');
    _layer = _tmx.getLayer(LAYER_NAME);

    if(RANDOM_START_GOAL) {
      // スタート地点・ゴール地点をランダムにする
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

//    var AUTOTILE = FlxGraphic.fromClass(GraphicAuto);
    var AUTOTILE = "assets/data/autotiles.png";

    var csv = _tmx.getLayerCsv(LAYER_NAME);

    if(false)
    {
      // 除外するタイル
      var r = ~/(17|18|19|20)/g; // ピットを1に置き換える
      csv = r.replace(csv, "1");
    }

    var r = ~/([\d]{2,}|[2-9])/g; // 0と1以外は置き換える
    csv = r.replace(csv, "0");    // 0に置き換える
    _map = new FlxTilemap();
    _map.loadMapFromCSV(csv, AUTOTILE, 0, 0, AUTO);
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
    if(POSITION_TO_WORLD) {
      pt.x = Field.toWorldX(pt.x);
      pt.y = Field.toWorldY(pt.y);
    }
    return pt;
  }

  /**
   * ゴール地点を取得する
   **/
  public static function getGoalPosition():FlxPoint {
    var layer = _tmx.getLayer(LAYER_NAME);
    var pt = layer.searchRandom(CHIP_GOAL);
    if(POSITION_TO_WORLD) {
      pt.x = Field.toWorldX(pt.x);
      pt.y = Field.toWorldY(pt.y);
    }
    return pt;
  }

  /**
   * 拠点の座標を取得する
   **/
  public static function getFlagPosition():FlxPoint {
    var layer = _tmx.getLayer(LAYER_NAME);
    var pt = layer.searchRandom(CHIP_FLAG);
    if(POSITION_TO_WORLD) {
      pt.x = Field.toWorldX(pt.x);
      pt.y = Field.toWorldY(pt.y);
    }
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
        /*
        case CHIP_FLOOR:
          Floor.add(false, x, y);
        case CHIP_FLOOR2:
          Floor.add(true, x, y);
        */
        case CHIP_SPIKE:
          Spike.add(Dir.None, x, y);
        case CHIP_HOOK:
          Hook.add(x, y);
        case CHIP_SPIKE_UP:
          Spike.add(Dir.Up, x, y);
        case CHIP_SPIKE_DOWN:
          Spike.add(Dir.Down, x, y);
        case CHIP_SPIKE_LEFT:
          Spike.add(Dir.Left, x, y);
        case CHIP_SPIKE_RIGHT:
          Spike.add(Dir.Right, x, y);
        /*
        case CHIP_BLOCK:
          Block.add(x, y);
        case CHIP_TRIGGER_SPIKE_DOWN:
          Trigger.add(x, y);
        case CHIP_PIT:
          Pit.add(Dir.Up, x, y);
        case CHIP_PIT_LEFT:
          Pit.add(Dir.Left, x, y);
        case CHIP_PIT_RIGHT:
          Pit.add(Dir.Right, x, y);
        case CHIP_PIT_DOWN:
          Pit.add(Dir.Down, x, y);
        */
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
   * 座標をグリッドに合わせる
   **/
  public static function snapGrid(a:Float):Float {
    return Std.int(a / GRID_SIZE) * GRID_SIZE;
  }
}

