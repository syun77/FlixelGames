package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import jp_2dgames.lib.Input;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var MOVE_SPEED:Float = 300.0;

  // 向き
  var _dir:Dir;
  // 歩いているかどうか
  var _bWalk:Bool;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _dir = Dir.Down;
    _bWalk = false;
    _playAnim();
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
      _bWalk = false;
      return;
    }
    _dir = dir;
    var deg = DirUtil.toAngle(_dir);
    setVelocity(deg, MOVE_SPEED);

    // 動いているフラグを立てる
    _bWalk = true;

    // アニメ再生
    _playAnim();
  }

  function _shot():Void {
    if(Input.press.B == false) {
      // 撃たない
      return;
    }

    var angle = DirUtil.toAngle(_dir);
    Shot.add(xcenter, ycenter, angle, 500);
  }

  /**
   * アニメーション再生
   **/
  function _playAnim():Void {
    animation.play('${_dir}${_bWalk}');
  }

  /**
   * アニメーションを登録
   **/
  function _registerAnim():Void {
    var spd:Int = 2;
    var bWalk:Bool = false;
    animation.add('${Dir.Left}${bWalk}', [0, 1], spd);
    animation.add('${Dir.Up}${bWalk}', [4, 5], spd);
    animation.add('${Dir.Right}${bWalk}', [8, 9], spd);
    animation.add('${Dir.Down}${bWalk}', [12, 13], spd);

    spd = 6;
    bWalk = true;
    animation.add('${Dir.Left}${bWalk}', [2, 3], spd);
    animation.add('${Dir.Up}${bWalk}', [6, 7], spd);
    animation.add('${Dir.Right}${bWalk}', [10, 11], spd);
    animation.add('${Dir.Down}${bWalk}', [14, 15], spd);
  }
}
