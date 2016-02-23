package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var MOVE_SPEED:Float = 200.0;

  var _angle:Float;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_PERSON);
    _angle = 270;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _move();
    _shot();
  }

  /**
   * 移動する
   **/
  function _move():Void {
    velocity.set();
    var angleNext = DirUtil.getInputAngle();
    if(angleNext == null) {
      // 動いていない
      return;
    }
    _angle = angleNext;
    var deg = angleNext;
    setVelocity(deg, MOVE_SPEED);
  }

  function _shot():Void {
    if(Input.press.B == false) {
      // 撃たない
      return;
    }

    Shot.add(xcenter, ycenter, _angle, 500);
  }
}
