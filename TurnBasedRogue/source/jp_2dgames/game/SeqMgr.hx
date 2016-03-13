package jp_2dgames.game;
import jp_2dgames.game.token.Player;

/**
 * シーケンス管理
 **/
class SeqMgr {

  var _player:Player;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    _player = player;
  }

  /**
   * 更新
   **/
  public function proc():Void {
    _player.proc();
  }
}
