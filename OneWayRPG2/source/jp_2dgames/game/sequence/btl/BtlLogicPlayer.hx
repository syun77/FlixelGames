package jp_2dgames.game.sequence.btl;

/**
 * 演出状態
 **/
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.sequence.btl.BtlLogic.BtlLogicAttack;
import jp_2dgames.game.gui.message.Message;
private enum State {
  None;
  Start;
  End;
}

/**
 * バトル演出の再生
 **/
class BtlLogicPlayer {

  // 状態
  static var _state:State = State.None;
  // 演出データ
  static var _data:BtlLogicData = null;

  /**
   * 初期化
   **/
  public static function init(data:BtlLogicData):Void {
    _data = data;
    _state = State.Start;
  }

  /**
   * 演出が終了したかどうか
   **/
  public static function isEnd():Bool {
    return _state == State.End;
  }

  /**
   * 更新
   **/
  public static function proc(elapsed:Float, owner:SeqMgr):Void {
    if(_data.count <= 0) {
      // 行動終了
      return;
    }
    if(owner.isEndWait() == false) {
      // 演出中
      return;
    }

    switch(_data.type) {
      case BtlLogic.None:
        // 何もしない

      case BtlLogic.Attack(type, prm):
        // 攻撃
        // ダメージ計算
        var damage = BtlCalc.damage(owner, prm, _data.actor, _data.target);
        _data.target.damage(damage);

        _data.count--;
        switch(type) {
          case BtlLogicAttack.Normal:
            // 1回攻撃
            owner.startWait();
          case BtlLogicAttack.Multi:
            // 複数回攻撃
            if(_data.count <= 0) {
              owner.startWait();
            }
            else {
              owner.startWaitHalf();
            }
        }

      case BtlLogic.Recover(prm):
        // 回復
        var hp = prm.hp;
        _data.target.recover(hp);
        var name = _data.actor.getName();
        Message.push2(Msg.RECOVER_HP, [name, hp]);
        owner.startWait();
        _data.count--;
    }

    if(_data.count <= 0) {
      // 演出終了
      _state = State.End;
    }
  }
}
