package jp_2dgames.game.gui.message;

import jp_2dgames.lib.CsvLoader;

/**
 * UIのメッセージ管理
 **/
class UIMsg {
  public static inline var ATTACK:Int          = 1;  // 攻撃力
  public static inline var DEFENSE:Int         = 2;  // 守備力
  public static inline var YES:Int             = 3;  // はい
  public static inline var NO:Int              = 4;  // いいえ
  public static inline var ITEM_CHANGE         = 5;  // アイテムを捨てて手に入れる
  public static inline var CANCEL:Int          = 6;  // キャンセル
  public static inline var CMD_ATK:Int         = 7;  // コマンド・攻撃
  public static inline var CMD_ITEM:Int        = 8;  // コマンド・アイテム
  public static inline var CMD_ESCAPE:Int      = 9;  // コマンド・逃走
  public static inline var CMD_ENEMY_ALL:Int   = 10; // コマンド・敵全体
  public static inline var MENU:Int            = 11; // メニュー
  public static inline var NEXT_FLOOR:Int      = 12; // 次のフロアに進む
  public static inline var SHOP:Int            = 13; // ショップ
  public static inline var SHOP_BUY:Int        = 14; // ショップ (購入)
  public static inline var SHOP_ITEM_SELL:Int  = 15; // ショップ (アイテム売却)
  public static inline var SHOP_SKILL_SELL:Int = 16; // ショップ (スキル売却)
  public static inline var SKILL_VIEW:Int      = 17; // スキル確認
  public static inline var ITEM_DROP:Int       = 18; // アイテムを捨てる
  public static inline var DEL_CONFIRM:Int     = 19; // 削除確認メッセージ
  public static inline var STATUS_STR:Int      = 20; // 力
  public static inline var STATUS_VIT:Int      = 21; // 体力
  public static inline var STATUS_AGI:Int      = 22; // 素早さ
  public static inline var STATUS_MAG:Int      = 23; // 魔力
  public static inline var SHOP_RECOVERY:Int   = 24; // ショップ（回復）
  public static inline var SHOP_REC_LITTLE:Int = 25; // ショップ（回復→10%）
  public static inline var SHOP_REC_FULL:Int   = 26; // ショップ（回復→全回復）
  public static inline var MSG_REC_LITTLE:Int  = 27; // ショップメッセージ（回復→10%）
  public static inline var MSG_REC_FULL:Int    = 28; // ショップメッセージ（回復→全回復）
  public static inline var FOOD:Int            = 29; // 食糧
  public static inline var MSG_FOOD:Int        = 30; // 食糧の詳細説明
  public static inline var MONSTER_APPEAR:Int  = 31; // モンスター出現
  public static inline var ITEM_FOUND:Int      = 32; // アイテムを見つけた
  public static inline var MONEY_FOUND:Int     = 33; // お金を拾った
  public static inline var FIELD_EFFECT:Int    = 34; // 地形効果
  public static inline var FIELD_DAMAGE:Int    = 35; // 地形効果：ダメージ
  public static inline var FIELD_POISON:Int    = 36; // 地形効果：毒

  private static var _csv:CsvLoader = null;
  /**
   * CSV読み込み
   **/
  public static function load():Void {
    _csv = new CsvLoader(Reg.PATH_CSV_UI_MSG);
  }

  /**
   * メッセージテキスト取得
   **/
  public static function get(ID:Int):String {
    return _csv.getString(ID, "msg");
  }

  public static function get2(ID:Int, args:Array<Dynamic>):String {
    var msg = get(ID);
    if(args != null) {
      var idx:Int = 1;
      for(val in args) {
        msg = StringTools.replace(msg, '<val${idx}>', '${val}');
        idx++;
      }
    }

    return msg;
  }
}
