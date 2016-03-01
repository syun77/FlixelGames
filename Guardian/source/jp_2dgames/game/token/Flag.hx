package jp_2dgames.game.token;

/**
 * 拠点
 **/
class Flag extends Token {
  public function new(X:Float, Y:Float) {
    X -= 8;
    Y -= 8;
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_FLAG);
  }
}
