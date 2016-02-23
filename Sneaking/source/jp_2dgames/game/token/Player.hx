package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.Input;
import flixel.util.FlxColor;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var MOVE_SPEED:Float = 200.0;

  var _dir:Dir;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_PERSON);
    _dir = Dir.Down;
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
    var dir = DirUtil.getInputDirection();
    if(dir == Dir.None) {
      // 動いていない
      return;
    }
    _dir = dir;
    var deg = DirUtil.toAngle(_dir);
    setVelocity(deg, MOVE_SPEED);
  }

  function _shot():Void {
    if(Input.press.B == false) {
      // 撃たない
      return;
    }

    var angle = DirUtil.toAngle(_dir);
    Shot.add(xcenter, ycenter, angle, 500);
  }
}
