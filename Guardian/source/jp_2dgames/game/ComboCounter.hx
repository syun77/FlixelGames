package jp_2dgames.game;

import jp_2dgames.game.global.Global;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * コンボカウンタ
 **/
class ComboCounter extends FlxGroup {

  // コンボ有効秒数
  static inline var TIMER:Float = 1.0;
  static inline var TIMER_SCORE:Int = 90;

  var _count:Int = 0;
  var _timer:Float = 0.0;
  var _cbFinished:Int->Void; // コンボ終了時のコールバック
  var _txt:FlxText;
  var _txtScore:FlxText;
  var _tScore:Int = 0; // スコアタイマー

  /**
   * コンストラクタ
   **/
  public function new(func:Int->Void) {
    super();
    _cbFinished = func;
    _txt = new FlxText(4, 16);
    _txt.visible = false;
    this.add(_txt);
    _txtScore = new FlxText(FlxG.width, 16+12);
    _txtScore.visible = false;
    this.add(_txtScore);
  }

  /**
   * コンボ数加算
   **/
  public function addCombo():Void {
    _count++;
    _timer = TIMER;
    _txt.visible = true;
    _txt.text = '${_count} combo';
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
        // スコア
        var score = 10 * _count;
        _txtScore.text = '+${score}';
        _txtScore.visible = true;
        _tScore = TIMER_SCORE;
        Global.addScore(score);

        _cbFinished(_count);
        _count = 0;
        _txt.visible = false;
      }
    }

    if(_tScore > 0) {
      _tScore--;
      if(_tScore < 30) {
        _txtScore.visible = _tScore%4 >= 2;
      }
    }
  }


}
