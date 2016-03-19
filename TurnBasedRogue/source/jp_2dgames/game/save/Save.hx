package jp_2dgames.game.save;

#if neko
import jp_2dgames.game.token.Heart;
import jp_2dgames.game.item.ItemType;
import jp_2dgames.game.item.Inventory;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.actor.Params;
import flixel.util.FlxSave;
import jp_2dgames.lib.Array2D;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.game.global.Global;
import sys.io.File;
#end
import haxe.Json;

/**
 * ロード種別
 **/
enum LoadType {
  All;  // すべてロードする
  Glob; // グローバルデータのみ
}

/**
 * グローバルデータ
 **/
private class _Global {
  public var level:Int = 0;
  public var turn:Int  = 0;
  public function new() {}
  // セーブ
  public function save() {
    level = Global.level;
    turn  = Global.turn;
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setLevel(data.level);
    Global.setTurn(data.turn);
  }
}

/**
 * プレイヤーデータ
 **/
private class _Player {
  public var x:Int = 0;
  public var y:Int = 0;
  public var dir:String = "down";
  public var params:Params;
  public var badstatus:String = "none";

  public function new() {
  }
  // セーブ
  public function save() {
    var p = cast(FlxG.state, PlayState).player;
    x = p.xchip;
    y = p.ychip;
    dir = DirUtil.toString(p.dir);
    params = p.params;
  }
  // ロード
  public function load(data:Dynamic) {
    var p = cast(FlxG.state, PlayState).player;
    var dir = DirUtil.fromString(data.dir);
    var prms:Params = new Params();
    prms.copyFromDynamic(data.params);
    Global.initPlayer(p, data.x, data.y, dir, prms);
  }
}


/**
 * 敵データ
 **/
private class _Enemy {
  public var x:Int = 0;
  public var y:Int = 0;
  public var dir:String = "down";
  public var params:Params;

  public function new() {
  }
}
private class _Enemies {
  public var array:Array<_Enemy>;

  public function new() {
    array = new Array<_Enemy>();
  }
  // セーブ
  public function save() {
    // いったん初期化
    array = new Array<_Enemy>();

    var func = function(e:Enemy) {
      var e2 = new _Enemy();
      e2.x = e.xchip;
      e2.y = e.ychip;
      e2.dir = "down"; // TODO:
      e2.params = e.params;
      array.push(e2);
    }

    Enemy.forEachAlive(func);
  }
  // ロード
  public function load(data:Dynamic) {
    // 敵を全部消す
    Enemy.forEachAlive(function(e:Enemy) e.kill());
    var arr:Array<Dynamic> = data.array;
    // 作り直し
    for(e2 in arr) {
      var dir = DirUtil.fromString(e2.dir);
      var prms:Params = new Params();
      prms.copyFromDynamic(e2.params);
      Enemy.add(e2.x, e2.y, dir, prms);
    }
  }
}

/**
 * アイテムデータ
 **/
private class _Item {
  public var x:Int = 0;
  public var y:Int = 0;
  public var id:Int = 0;

  public function new() {
  }
}
private class _Items {
  public var array:Array<_Item>;

  public function new() {
    array = new Array<_Item>();
  }
  // セーブ
  public function save() {
    // いったん初期化
    array = new Array<_Item>();

    var func = function(item:DropItem) {
      var i = new _Item();
      i.x = item.xchip;
      i.y = item.ychip;
      i.id = item.ID;
      array.push(i);
    }

    DropItem.parent.forEachAlive(func);
  }
  // ロード
  public function load(data:Dynamic) {
    // アイテムを全部消す
    DropItem.parent.forEachAlive(function(item:DropItem) item.kill());
    var arr:Array<Dynamic> = data.array;
    // 作り直し
    for(i in arr) {
      // 通常アイテム
      DropItem.add(i.x, i.y, i.id);
    }
  }
}

/**
 * ハート
 **/
private class _Heart {
  public var x:Int = 0;
  public var y:Int = 0;
  public function new() {
  }
}

private class _Hearts {
  public var array:Array<_Heart>;
  public function new() {
    array = new Array<_Heart>();
  }
  // セーブ
  public function save() {
    // いったん初期化
    array = new Array<_Heart>();

    var func = function(heart:Heart) {
      var h = new _Heart();
      h.x = heart.xchip;
      h.y = heart.ychip;
      array.push(h);
    }

    Heart.parent.forEachAlive(func);
  }
  // ロード
  public function load(data:Dynamic) {
    // ハートを全部消す
    Heart.parent.forEachAlive(function(heart:Heart) heart.kill());
    var arr:Array<Dynamic> = data.array;
    // 作り直し
    for(h in arr) {
      Heart.add(h.x, h.y);
    }
  }
}

/**
 * インベントリ
 **/
private class _Inventory {
  var items:Array<Int>;
  var types:Array<Int>;
  public function new() {
  }
  public function save() {
    items = new Array<Int>();
    types = new Array<Int>();

    Inventory.forEachItem(function(itemid:Int) {
      items.push(itemid);
    });

    ItemType.forEachTable(function(type:Int) {
      types.push(type);
    });
  }
  public function load(data:Dynamic) {
    var itemList:Array<Int> = data.items;
    var typeList:Array<Int> = data.types;

    Inventory.set(itemList);
    ItemType.setTable(typeList);
  }
}

/**
 * マップデータ
 **/
private class _Map {
  public var width:Int = 0;
  public var height:Int = 0;
  public var data:String = "";

  public function new() {
  }
  // セーブ
  public function save() {
    var layer = Field.getLayer();
    width = layer.width;
    height = layer.height;
    data = layer.getCsv();
  }
  // ロード
  public function load(data:Dynamic) {
    var state = cast(FlxG.state, PlayState);
    var w = data.width;
    var h = data.height;
    var layer = new Array2D();
    layer.setCsv(w, h, data.data);
    Field.setLayer(layer);
  }
}

/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var player:_Player;
  public var enemies:_Enemies;
  public var items:_Items;
  public var hearts:_Hearts;
  public var inventory:_Inventory;
  public var map:_Map;

  public function new() {
    global = new _Global();
    player = new _Player();
    enemies = new _Enemies();
    items = new _Items();
    hearts = new _Hearts();
    inventory = new _Inventory();
    map = new _Map();
  }

  // セーブ
  public function save():Void {
    global.save();
    player.save();
    enemies.save();
    items.save();
    hearts.save();
    inventory.save();
    map.save();
  }

  // ロード
  public function load(type:LoadType, data:Dynamic):Void {
    switch(type) {
      case LoadType.All:
        // すべてのデータをロードする
        global.load(data.global);
        player.load(data.player);
        enemies.load(data.enemies);
        items.load(data.items);
        hearts.load(data.hearts);
        inventory.load(data.inventory);
        map.load(data.map);

      case LoadType.Glob:
        // グローバルデータのみロードする
        global.load(data.global);
    }
  }
}

/**
 * セーブ管理
 **/
class Save {

  #if neko
	// セーブデータ保存先
	static inline var PATH_SAVE = "/Users/syun/Desktop/FlixelGames/TurnBasedRogue/save.txt";
#end

  /**
   * セーブする
   **/
  public static function save(bFromText:Bool, bShowLog:Bool):Void {

    var data = new SaveData();
    data.save();

    var str = Json.stringify(data);

    if(bFromText) {
      // テキストへセーブ
#if neko
    sys.io.File.saveContent(PATH_SAVE, str);
    if(bShowLog) {
      trace("save -------------------");
      trace(data);
    }
#end
    }
    else {
      // セーブデータ領域へ書き込み
      var saveutil = new FlxSave();
      saveutil.bind("SAVEDATA");
      saveutil.data.playdata = str;
      saveutil.flush();
    }
  }

  /**
	 * ロードする
	 * @param type ロード種別
	 * @param bFromText テキストから読み込む
	 * @param bShowLog ログを表示する
	 **/
  public static function load(type:LoadType, bFromText:Bool, bShowLog:Bool):Void {
    var str = "";
#if neko
    str = sys.io.File.getContent(PATH_SAVE);
    if(bShowLog) {
      trace("load -------------------");
      trace(str);
    }
#end
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(bFromText) {
      // テキストファイルからロードする
      var data = Json.parse(str);
      var s = new SaveData();
      s.load(type, data);
    }
    else {
      if(isContinue()) {
        // ロード実行
        var data = Json.parse(saveutil.data.playdata);
        var s = new SaveData();
        s.load(type, data);
      }
    }
  }

  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    saveutil.erase();
  }

  /**
   * コンティニューを選べるかどうか
   **/
  public static function isContinue():Bool {

    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(saveutil.data == null) {
      return false;
    }
    if(saveutil.data.playdata == null) {
      return false;
    }

    return true;
  }
}
