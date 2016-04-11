package jp_2dgames.game;

/**
 * 状態
 **/
private enum State {
  Init;      // 初期化
  Main;      // メイン
  Success;   // レベルクリア
  Failed;    // ゲームオーバー
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_SUCCESS:Int = 1;
  public static var RET_FAILED:Int  = 2;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡

  var _state:State;
  var _bDead:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new() {
    _state  = State.Init;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;

    switch(_state) {
      case State.Init:
        _state = State.Main;
      case State.Main:
        _updateMain();
      case State.Success:
        ret = RET_SUCCESS;
      case State.Failed:
        ret = RET_FAILED;
    }

    if(_bDead) {
      // プレイヤー死亡
      return RET_DEAD;
    }

    return ret;
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
  }

}
