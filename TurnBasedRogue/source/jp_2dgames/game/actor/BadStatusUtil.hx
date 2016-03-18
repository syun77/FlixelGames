package jp_2dgames.game.actor;

/**
 * バッドステータス定数
 **/
enum BadStatus {
  None;      // なし
  Sleep;     // 眠り
  Paralysis; // 麻痺
  Slow;      // 移動力低下
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {
  /**
   * バッドステータス定数を文字列に変換する
   **/
  public static function toString(stt:BadStatus):String {
    return switch(stt) {
      case BadStatus.None:      "none";
      case BadStatus.Sleep:     "sleep";
      case BadStatus.Paralysis: "paralysis";
      case BadStatus.Slow:      "slow";
    }
  }

  /**
   * バッドステータス文字列を定数に変換する
   **/
  public static function fromString(str:String):BadStatus {
    return switch(str) {
      case "none":      BadStatus.None;
      case "sleep":     BadStatus.Sleep;
      case "paralysis": BadStatus.Paralysis;
      case "slow":      BadStatus.Slow;
      default:          BadStatus.None;
    }
  }
}
