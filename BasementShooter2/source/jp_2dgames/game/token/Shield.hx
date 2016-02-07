package jp_2dgames.game.token;

/**
 * シールド
 **/
class Shield extends Token {
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_SHIELD);
  }

  override public function get_radius() {
    return 64;
  }
}
