package jp_2dgames.game;

import flixel.FlxBasic;
/**
 * コンボカウンタ
 **/
class ComboCounter extends FlxBasic {

  // コンボ有効秒数
  static inline var TIMER:Float = 1.0;

  var _count:Int = 0;
  var _timer:Float = 0.0;
  var _cbFinished:Int->Void; // コンボ終了時のコールバック

  /**
   * コンストラクタ
   **/
  public function new(func:Int->Void) {
    _cbFinished = func;
    super();
  }

  /**
   * コンボ数加算
   **/
  public function add():Void {
    _count++;
    _timer = TIMER;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_timer > 0) {
      _timer -= elapsed;
      if(_timer <= 0) {
        // コンボ終了
        _cbFinished(_count);
        _count = 0;
      }
    }
  }


}
