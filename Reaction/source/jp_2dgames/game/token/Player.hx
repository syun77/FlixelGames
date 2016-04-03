package jp_2dgames.game.token;

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

  // ----------------------------------
  // ■フィールド
  var _anim:Anim = Anim.Standby;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _playAnim();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
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
