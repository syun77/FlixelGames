package jp_2dgames.game.token;

import flixel.util.FlxRandom;
import jp_2dgames.game.particle.ParticleSmoke;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.token.enemy.BossJellyfish;
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
  Jellyfish; // クラゲ
  WillOWisp; // ウィル・オ・ウィスプ
  Griffin;   // グリフォン
}

/**
 * ボス
 **/
class Boss extends Enemy {

  public static function levelToBossType(level:Int):BossType {
    switch(level%3) {
      case 0: return BossType.Jellyfish;
      case 1: return BossType.WillOWisp;
      default: return BossType.Griffin;
    }
  }

  // ============================================
  // ■メンバ変数
  var _type2:BossType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BOSS, true, 32, 32);
    animation.add('${BossType.Jellyfish}',  [0, 1], 2);
    animation.add('${BossType.WillOWisp}', [8, 9], 2);
    animation.add('${BossType.Griffin}',  [4, 5], 2);
  }

  /**
   * 初期化
   **/
  public function init2(type:BossType, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _type = EnemyType.None;
    _type2 = type;
    flipX = false;
    drag.set();
    animation.play('${_type2}');
    switch(_type2) {
      case BossType.Jellyfish:
        _ai = new BossJellyfish(this);
      case BossType.WillOWisp:
        _ai = new BossJellyfish(this);
      case BossType.Griffin:
        _ai = new BossJellyfish(this);
    }

    _hp = 20 + 5 * Global.getLevel();
    _hpmax = _hp;

    // 出現演出
    for(i in 0...4) {
      var px = xcenter + FlxRandom.intRanged(-8, 8);
      var py = ycenter + FlxRandom.intRanged(-8, 8);
      ParticleSmoke.start("enemy", px, py);
    }
  }

  /**
   * 消滅
   **/
  override public function vanish():Void {
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);

    Global.addScore(1000);
    FlxG.camera.shake(0.02, 0.6);
    kill();

    _ai = null;

    Snd.playSe("explosion");
  }


  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    decayVelocity(0.95);
  }
}
