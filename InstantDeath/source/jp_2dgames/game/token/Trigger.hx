package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil.Dir;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * トリガーコリジョン
 **/
class Trigger extends Token {

  public static var parent:FlxTypedGroup<Trigger> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Trigger>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(x:Float, y:Float):Trigger {
    var trigger = parent.recycle(Trigger);
    trigger.init(x, y);
    return trigger;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK);
    visible = false;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }

  /**
   * アクション発動
   **/
  public function action():Void {

    // 一番近くにいる真上の鉄球を落下させる
    var sp:Spike = null;
    var distance:Float = 9999;
    Spike.parent.forEachAlive(function(spike:Spike) {
      if(spike.dir == Dir.None) {
        // 止まっている
        if(spike.x == x) {
          // X座標が同じ
          var d = y - spike.y;
          if(d > 0) {
            // 上にいる
            if(d < distance) {
              // より近い
              distance = d;
              sp = spike;
            }
          }
        }
      }
    });

    if(sp != null) {
      // 高速落下
      sp.velocity.y = 500;
    }

    kill();
  }
}
