package jp_2dgames.game.token;

import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  // ---------------------------------------------------------
  // ■フィールド


  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    makeGraphic(16, 16, FlxColor.BLUE);
  }
}
