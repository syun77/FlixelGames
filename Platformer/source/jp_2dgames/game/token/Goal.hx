package jp_2dgames.game.token;

/**
 * ゴール
 **/
class Goal extends Token {
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_CHARSET, true, CharSet.WIDTH, CharSet.HEIGHT);
    var anim = [for(i in 0...4) CharSet.OFS_GATE+i];
    animation.add("play", anim, 4);
    animation.play("play");
  }
}
