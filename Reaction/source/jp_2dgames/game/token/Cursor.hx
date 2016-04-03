package jp_2dgames.game.token;

import jp_2dgames.lib.Input;

/**
 * カーソル
 **/
class Cursor extends Token {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_CURSOR, true);
    animation.add("play", [0, 1], 3);
    animation.play("play");

    _updatePosition();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _updatePosition();
  }

  /**
   * 座標を更新
   **/
  function _updatePosition():Void {
    x = Input.x - width/2;
    y = Input.y - height/2;
  }
}
