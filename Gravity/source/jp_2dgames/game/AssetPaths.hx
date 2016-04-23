package jp_2dgames.game;
class AssetPaths {
  public static inline var IMAGE_EFFECT = "assets/images/effect.png";
  public static inline var IMAGE_FLAG = "assets/images/flag.png";
  public static inline var IMAGE_ENEMY = "assets/images/enemy.png";
  public static inline var IMAGE_BLAST = "assets/images/blast.png";
  public static inline var IMAGE_INFANTRY = "assets/images/infantry.png";
  public static inline var IMAGE_SHOT = "assets/images/shot.png";
  public static inline var IMAGE_CURSOR = "assets/images/cursor.png";
  public static inline var IMAGE_PLAYER = "assets/images/player.png";
  public static inline var IMAGE_COIN = "assets/images/coin.png";
  public static inline var IMAGE_BULLET = "assets/images/bullet.png";
  public static inline var IMAGE_PANEL = "assets/images/panel.png";
  public static inline var IMAGE_ICON = "assets/images/icon.png";
  public static inline var IMAGE_BUTTON = "assets/images/button.png";
  public static inline var IMAGE_LIGHT = "assets/images/light.png";
  public static inline var IMAGE_ITEM = "assets/images/item.png";
  public static inline var CSV_ENEMY = "assets/data/enemy.csv";
  public static inline var IMAGE_CURSOR3 = "assets/images/cursor3.png";
  public static inline var IMAGE_HEART = "assets/images/heart.png";
  public static inline var IMAGE_SPIKE = "assets/images/spike.png";
  public static inline var IMAGE_DOOR = "assets/images/door.png";
  public static inline var IMAGE_PIT = "assets/images/pit.png";
  public static inline var IMAGE_TILESET = "assets/data/tileset.png";
  public static inline var IMAGE_BLOCK = "assets/images/block.png";
  public static inline var IMAGE_BARRIER = "assets/images/barrier.png";
  public static inline var IMAGE_HORMING = "assets/images/horming.png";
  public static inline var IMAGE_BG = "assets/images/back.png";
  public static inline var IMAGE_AUTOTILES = "assets/data/levels/autotiles.png";
  public static inline var IMAGE_JOINT = "assets/images/joint.png";
  public static inline var IMAGE_HOOK = "assets/images/hook.png";
  public static inline var IMAGE_FLOOR = "assets/images/floor.png";

  public static function getAIScript(script:String):String {
    return 'assets/data/ai/${script}.csv';
  }
}
