package jp_2dgames.game;

/**
 * メインゲーム中のグローバルデータ
 **/
class Global {

  // スコア
  static var _score:Int;

  /**
   * ゲーム開始前の初期化
   **/
  public static function init():Void {
    _score = 0;
  }

  /**
   * スコア加算
   **/
  public static function addScore(v:Int):Void {
    _score += v;
  }

  /**
   * スコア取得
   **/
  public static function getScore():Int {
    return _score;
  }

}
