package jp_2dgames.game;
import flixel.FlxG;
import jp_2dgames.lib.MyMath;
import jp_2dgames.game.token.Block;
import jp_2dgames.game.util.Field;
import flixel.util.FlxRandom;
import flixel.FlxBasic;
class LevelMgr extends FlxBasic {

  // 出現頻度
  static inline var FREQ_FIRST:Int = 60;
  static inline var FREQ_LAST:Int = 20;

  var _timer:Int = 0;
  var _freq:Int = 0;
  var _bStop:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _timer = 0;
    _freq = FREQ_FIRST;

    FlxG.watch.add(this, "_freq", "freq");
  }

  public function stop():Void {
    _bStop = true;
  }

  override public function update():Void {
    super.update();

    if(_bStop) {
      return;
    }

    _timer++;
    var rank = MyMath.calcRank3MIN(_timer*3);
    rank = FREQ_FIRST / rank;
    if(rank < FREQ_LAST) {
      rank = FREQ_LAST;
    }
    _freq = Std.int(rank);

    // 出現数
    var cnt:Int = 1;
    if(_timer > 15 * 60) {
      cnt = FlxRandom.intRanged(1, 2);
    }
    else if(_timer > 60 * 60) {
      cnt = FlxRandom.intRanged(1, 3);
    }

    if(_timer%_freq == 0) {
      for(v in 0...cnt) {
        var i = FlxRandom.intRanged(1, Field.WIDTH-1);
        Block.add(i, 0);
      }
    }
  }
}
