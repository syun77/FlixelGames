package jp_2dgames.game.token;

import flixel.FlxSprite;

/**
 * 背景
 **/
class Bg extends FlxSprite {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BG);
  }
}
