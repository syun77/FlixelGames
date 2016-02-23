package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_PERSON);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    velocity.set();
    var angleNext = DirUtil.getInputAngle();
    if(angleNext == null) {
      return;
    }
    var deg = angleNext;
    setVelocity(deg, 200);
  }
}
