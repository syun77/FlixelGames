package jp_2dgames.game.actor;

/**
 * バッドステータス定数
 **/
enum BadStatus {
  None;      // なし
  Sleep;     // 眠り
  Paralysis; // 麻痺
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {
  /**
   * バッドステータス定数を文字列に変換する
   **/
  public static function toString(stt:BadStatus):String {
    switch(stt) {
      case BadStatus.None: return "none";
      case BadStatus.Sleep: return "sleep";
      case BadStatus.Paralysis: return "paralysis";
    }
  }

  /**
   * バッドステータス文字列を定数に変換する
   **/
  public static function fromString(str:String):BadStatus {
    switch(str) {
      case "none": return BadStatus.None;
      case "sleep": return BadStatus.Sleep;
      case "paralysis": return BadStatus.Paralysis;
      default: return BadStatus.None;
    }
  }
}
