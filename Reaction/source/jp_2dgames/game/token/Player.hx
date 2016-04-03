package jp_2dgames.game.token;

/**
 * アニメ定数
 **/
import jp_2dgames.lib.Input;
import jp_2dgames.lib.MyMath;
private enum Anim {
  Standby; // 待機中
  Danger;  // 危険
}

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var RADIUS:Float = 12.0;

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
  }

  /**
   * ショットを撃つ
   **/
  function _shot():Void {
    var dx = _cursor.xcenter - xcenter;
    var dy = _cursor.ycenter - ycenter;
    var rot = MyMath.atan2Ex(-dy, dx);
    Shot.add(xcenter, ycenter, rot, 200);
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
