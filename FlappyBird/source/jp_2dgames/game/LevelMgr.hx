package jp_2dgames.game;
import jp_2dgames.game.particle.ParticleStartLevel;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.token.Enemy;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.token.Boss;
import flixel.FlxBasic;

private enum State {
  Main; // メイン
  Wait; // 停止中
  Stop; // 完全に停止中
}

/**
 * レベル管理
 **/
class LevelMgr extends FlxBasic {

  // 次のレベル開始までのウェイト
  static inline var TIMER_WAIT:Int = 60;

  var _boss:Boss;
  var _state:State;
  var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new(boss:Boss) {
    super();
    _boss = boss;
    _boss.kill();
    _state = State.Stop;
    _timer = 0;
  }

  /**
   * ゲーム開始
   **/
  public function start():Void {
    _boss.revive();
    var level = Global.level;
    level -= 1;
    level = level % 3;
    _boss.init2(101 + level);
    _state = State.Main;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Main:
        if(_boss.exists == false) {
          // ボスを倒した
          // 少し停止する
          Enemy.parent.active = false;
          Bullet.parent.forEachAlive(function(b:Bullet) b.vanish());

          _timer = TIMER_WAIT;
          _state = State.Wait;
          Global.addLevel();
          ParticleStartLevel.start(FlxG.state);
        }
      case State.Wait:
        _timer--;
        if(_timer < 1) {
          // ボス出現
          Enemy.parent.active = true;
          start();
        }
      case State.Stop:
    }
  }
}
