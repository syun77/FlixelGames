package jp_2dgames.game.token;

/**
 * スクロールオブジェクト
 **/
class ScrollObj extends Token {
  public function new(X:Float, Y:Float) {
    super(X, Y);
//    visible = false;
  }

  /**
   * 速度を設定
   **/
  public function setSpeed(spd:Float):Void {
    velocity.y = -spd;
  }
}
