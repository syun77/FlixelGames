package jp_2dgames.game.item;

import flixel.FlxG;

/**
 * アイテム種別
 **/
class ItemType {

  public static inline var INVALID:Int = -1;
  public static inline var MAX:Int = 8;

  public static inline var HEAL:Int     = 0; // ターン数回復
  public static inline var LASER:Int    = 1; // 上下左右に攻撃
  public static inline var TELEPORT:Int = 2; // ランダムでワープ
  public static inline var SLEEP:Int    = 3; // すべての敵を眠らせる
  public static inline var WARP3:Int    = 4; // 3マス先までワープできる
  public static inline var MISSILE:Int  = 5; // 指定の敵を倒す
  public static inline var SWAP:Int     = 6; // 指定の敵と位置を入れ替える
  public static inline var SLOW:Int     = 7; // 敵が2ターンに1回しか移動できないようにする

  static var _table:Array<Int> = null;
  static var _ids:Array<Bool> = null;

  /**
   * アイテムIDに対応するアイテム種別を作成する
   **/
  public static function create():Void {
    _table = [for(i in 0...MAX) i];
    FlxG.random.shuffleArray(_table, 5);
    _ids = [for(i in 0...MAX) false];
  }
  public static function destroy():Void {
    _table = null;
    _ids = null;
  }

  /**
   * アイテムIDに対応する種別を取得する
   **/
  public static function get(id:Int):Int {
    return _table[id];
  }

  /**
   * 名前を取得
   **/
  public static function toName(type:Int):String {

    var tbl = [
      HEAL => "Heal",
      LASER => "Laser",
      TELEPORT => "Teleport",
      SLEEP => "Sleep",
      WARP3 => "Warp3",
      MISSILE => "Missile",
      SWAP => "Swap",
      SLOW => "Slow"
    ];

    return tbl[type];

    // 未識別の場合
    return "???";
  }

  public static function forEachTable(func:Int->Void):Void {
    for(type in _table) {
      func(type);
    }
  }

  public static function setTable(table:Array<Int>):Void {
    _table = table;
  }
}
