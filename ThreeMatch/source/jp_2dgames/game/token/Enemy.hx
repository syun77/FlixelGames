package jp_2dgames.game.token;

/**
 * 敵
 **/
import jp_2dgames.lib.MyMath;
import jp_2dgames.lib.Input;
class Enemy extends Token {

  var _eid:Int = 0;
  var _tAnim:Int = 0;

  public function new(X:Float, Y:Float) {
    super(X, Y);

    var sc = 0.15/2;
    scale.set(sc, sc);

    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 256, 256);
    _registerAnim();

    x -= width/2 * (1 - sc);
    y -= height/2 * (1 - sc);
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

    angle = 15 * MyMath.sinEx(_tAnim*2);

    if(Input.press.X) {
      _eid++;
      if(_eid >= 5) {
        _eid = 0;
      }
      _playAnim();
    }
  }

  function _playAnim():Void {
    animation.play('${_eid}');
  }

  function _registerAnim():Void {
    for(i in 0...5) {
      animation.add('${i}', [i], 1);
    }
  }
}
