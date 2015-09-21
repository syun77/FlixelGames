package jp_2dgames.game;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.token.Token;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.game.token.Item;
import jp_2dgames.game.token.Player;

/**
 * メインゲームのシーケンス管理
 **/
class SeqMgr {

  // procの返却値
  public static inline var RET_NONE:Int = 0;
  public static inline var RET_GAMEOVER:Int = 1;
  public static inline var RET_TIMEISUP:Int = 2;

  // スコア加算と見なされる距離
  static inline var SCORE_DISTANCE:Int = 100;


  var _player:Player;
  var _yprev:Float = 0;
  var _yincrease:Float = 0;

  /**
   * コンストラクタ
   **/
  public function new(player:Player) {
    _player = player;
    _yprev = _player.y;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    // 移動距離計算 (上に進むのでマイナスする)
    _yincrease += -(_player.y - _yprev);
    if(_yincrease > SCORE_DISTANCE) {
      var d = Math.floor(_yincrease / SCORE_DISTANCE);
      Global.addScore(d * 10);
      _yincrease -= d * SCORE_DISTANCE;
    }
    _yprev = _player.y;

    // 衝突判定
    _checkCollide();

    if(_player.alive == false) {
      // ゲームオーバー
      return RET_GAMEOVER;
    }

    if(LimitMgr.timesup()) {
      // 時間切れ
      return RET_TIMEISUP;
    }

    return RET_NONE;
  }

  /**
   * 衝突判定
   **/
  private function _checkCollide():Void {
    // プレイヤー vs アイテム
    Item.forEachAlive(function(item:Item) {
      if(Token.checkHitCircle(_player, item)) {
        // アイテム獲得
        item.vanish();
        // 速度上昇
        _player.addFrameTimer(60 * 60);

        Snd.playSe("powerup");
      }
    });
    // プレイヤー vs 敵
    Enemy.forEachAlive(function(e:Enemy) {
      if(Token.checkHitCircle(_player, e)) {
        _player.vanish();
      }
    });
  }
}
