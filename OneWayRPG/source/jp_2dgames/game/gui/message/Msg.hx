package jp_2dgames.game.gui.message;
class Msg {
  public static inline var DAMAGE_PLAYER:Int  = 1;  // プレイヤーへのダメージ
  public static inline var DAMAGE_ENEMY:Int   = 2;  // 敵へのダメージ
  public static inline var ATTACK_BEGIN:Int   = 3;  // 攻撃開始
  public static inline var DEFEAT_ENEMY:Int   = 4;  // 敵を倒した
  public static inline var BATTLE_WIN:Int     = 5;  // バトルに勝利した
  public static inline var DEAD:Int           = 6;  // 死亡
  public static inline var ITEM_USE:Int       = 7;  // アイテムを使った
  public static inline var RECOVER_HP:Int     = 8;  // HP回復
  public static inline var ESCAPE:Int         = 9;  // 逃走開始
  public static inline var ITEM_DROP:Int      = 10; // アイテムを落とした
  public static inline var ITEM_GET:Int       = 11; // アイテム入手
  public static inline var ITEM_CANT_GET:Int  = 12; // アイテムを入手できない
  public static inline var ITEM_DEL_GET:Int   = 13; // アイテムを捨てて拾う
  public static inline var ITEM_ABANDAN:Int   = 14; // アイテムをあきらめる
  public static inline var ITEM_SEL_DEL:Int   = 15; // 捨てるアイテムを選択
  public static inline var XP_GET:Int         = 16; // 経験値を獲得
  public static inline var LEVELUP:Int        = 17; // レベルアップ
  public static inline var RECOVER_HP_ALL:Int = 18; // HP全回復
  public static inline var SKILL_BEGIN:Int    = 19; // スキル発動
  public static inline var ATTACK_MISS:Int    = 20; // 攻撃回避
  public static inline var SKILL_MISS:Int     = 21; // スキル回避
  public static inline var PLAYER_DEAD:Int    = 22; // プレイヤー死亡
  public static inline var BST_POISON:Int     = 23; // バステ: 毒
  public static inline var BST_CONFUSION:Int  = 24; // バステ: 混乱
  public static inline var BST_CLOSE:Int      = 25; // バステ: 封印
  public static inline var BST_PARALYZE:Int   = 26; // バステ: 麻痺
  public static inline var BST_SLEEP:Int      = 27; // バステ: 眠り
  public static inline var BST_BLIND:Int      = 28; // バステ: 盲目
  public static inline var BST_CURSE:Int      = 29; // バステ: 呪い
  public static inline var BST_WEAK:Int       = 30; // バステ: 衰弱
  public static inline var NOT_ENOUGH_HP:Int  = 31; // HP不足
  public static inline var NOT_ENOUGH_TP:Int  = 32; // TP不足
  public static inline var ESCAPE_FAILED:Int  = 33; // 逃走失敗
  public static inline var SLEEPING:Int       = 34; // 眠っている
  public static inline var CLOSING:Int        = 35; // 封印されている
  public static inline var PARALYZING:Int     = 36; // 麻痺で動けない
  public static inline var BUFF_ATK_UP:Int    = 37; // 攻撃力アップ
  public static inline var BUFF_DEF_UP:Int    = 38; // 防御力アップ
  public static inline var BUFF_SPD_UP:Int    = 39; // 素早さアップ
  public static inline var BUFF_ATK_DOWN:Int  = 40; // 攻撃力ダウン
  public static inline var BUFF_DEF_DOWN:Int  = 41; // 防御力ダウン
  public static inline var BUFF_SPD_DOWN:Int  = 42; // 素早さダウン
  public static inline var ITEM_BUY:Int       = 43; // アイテム購入
  public static inline var ITEM_SELL:Int      = 44; // アイテム売却
  public static inline var ITEM_DEL:Int       = 45; // アイテムを捨てる
  public static inline var GROW_HPMAX:Int     = 46; // 最大HP上昇
  public static inline var GROW_STR:Int       = 47; // 力上昇
  public static inline var GROW_VIT:Int       = 48; // 体力上昇
  public static inline var GROW_AGI:Int       = 49; // 素早さ上昇
  public static inline var GROW_MAG:Int       = 50; // 魔力上昇
  public static inline var RECOVER_MP:Int     = 51; // MP回復
  public static inline var SKILL_CANT_BUY:Int = 52; // スキルが最大数に達しているので買えない
  public static inline var ACTION_STANDBY:Int = 53; // 何もしない
}