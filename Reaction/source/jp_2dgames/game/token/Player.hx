package jp_2dgames.game.token;

import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.lib.MyMath;
/**
 * アニメ定数
 **/
private enum Anim {
  Standby; // 待機中
  Danger;  // 危険
}

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var RADIUS:Float = 12.0;
  static inline var REACT_SPEED:Float = 100.0;
  static inline var MAX_SPEED:Float = 500.0;
  static inline var DRAG_SPEED:Float = 100.0;

  // ----------------------------------
  // ■フィールド
  var _anim:Anim = Anim.Standby;
  var _cursor:Cursor;
  var _rot:Float; // カーソルがある方向

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, cursor:Cursor) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _playAnim();

    maxVelocity.set(MAX_SPEED, MAX_SPEED);
    drag.set(DRAG_SPEED, DRAG_SPEED);

    _cursor = cursor;
    _rot = 0;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // ショットを撃つ
    if(Input.press.A) {
      _shot();
    }

    // 回転
    _rotate();

    // カベとの衝突で反動する
    _reflectWall();
  }

  /**
   * ショットを撃つ
   **/
  function _shot():Void {
    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var rot = MyMath.atan2Ex(-dy, dx);
    Shot.add(xcenter, ycenter, rot, 500);

    // 反動
    velocity.x -= REACT_SPEED * MyMath.cosEx(rot);
    velocity.y -= REACT_SPEED * -MyMath.sinEx(rot);
  }

  /**
   * 回転
   **/
  function _rotate():Void {
    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var rot = MyMath.atan2Ex(-dy, dx);
    var dRot = MyMath.deltaAngle(_rot, rot);
    _rot += dRot * 0.1;
    angle = 360 - _rot;
  }

  /**
   * カベとの衝突の反動
   **/
  function _reflectWall():Void {
    var x1 = 0;
    var y1 = 0;
    var x2 = FlxG.width - width;
    var y2 = FlxG.height - height;

    if(x < x1) {
      x = x1;
      velocity.x *= -1;
    }
    if(y < y1) {
      y = y1;
      velocity.y *= -1;
    }
    if(x > x2) {
      x = x2;
      velocity.x *= -1;
    }
    if(y > y2) {
      y = y2;
      velocity.y *= -1;
    }
  }

  /**
   * アニメーション再生
   **/
  function _playAnim():Void {
    animation.play('${_anim}');
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${Anim.Standby}', [0, 1], 2);
    animation.add('${Anim.Danger}', [0, 2], 2);
  }

  // ------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return RADIUS;
  }

}
