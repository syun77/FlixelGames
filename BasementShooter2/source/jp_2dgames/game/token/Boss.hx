package jp_2dgames.game.token;

import jp_2dgames.game.token.enemy.Enemy;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import jp_2dgames.game.token.enemy.EnemyAI;

/**
 * ボスの種類
 **/
enum BossType {
  First; //
}

/**
 * ボス
 **/
class Boss extends Enemy {


  // ============================================
  // ■メンバ変数
  var _type2:BossType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(32, 32, FlxColor.LIME);
  }

  /**
   * 初期化
   **/
  public function init2(type:BossType, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _type2 = type;
    _xreaction = 0;
    _yreaction = 0;
    _ai = null;
    flipX = false;
    drag.set();

    _hp = 100;
  }

  /**
   * 消滅
   **/
  override public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);

    Global.addScore(1000);
    FlxG.camera.shake(0.02, 0.3);
    kill();

    _ai = null;
  }


  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }
}
