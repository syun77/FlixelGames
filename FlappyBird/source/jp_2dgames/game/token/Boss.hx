package jp_2dgames.game.token;

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
    color  = FlxColor.GREEN;
    makeGraphic(_size, _size);
    _timer = 0;
    _ai    = null;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _timer++;
    if(_timer%60 == 0) {
      Enemy.add(1, Attribute.Red, xcenter, ycenter, 135, 100);
    }
  }
}
