package jp_2dgames.game.sequence;

/**
 * ダンジョンイベント
 **/
enum DgEvent {
  None;    // 何も起こらなかった
  Encount; // 敵出現
  Itemget; // アイテム獲得
  Stair;   // 階段を見つけた
}
