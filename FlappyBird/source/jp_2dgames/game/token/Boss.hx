package jp_2dgames.game.token;

import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.util.FlxColor;

/**
 * ボス
 **/
class Boss extends Enemy {

  // ------------------------------------------
  // ■フィールド
  var _hpmax:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init2(eid:Int, X:Float, Y:Float):Void {
    _eid = eid;
    x = X;
    y = Y;
    _size  = EnemyInfo.getRadius(_eid);
    _hp    = EnemyInfo.getHp(_eid);
    _hpmax = _hp;
    _tDestroy = EnemyInfo.getDestroy(_eid);
    color  = FlxColor.GREEN;
    makeGraphic(_size, _size);
    _timer = 0;
    _ai    = null;
  }

  /**
   * 自爆
   **/
  override public function selfDestruction():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.GREEN);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.GREEN);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_timer%60 == 0) {
      Enemy.add(2, Attribute.Red, xcenter, ycenter, 135, 200);
      _timer++;
    }
  }
}
