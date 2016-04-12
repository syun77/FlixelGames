package jp_2dgames.game;

/**
 * 状態
 **/
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.DirUtil.Dir;
import flixel.FlxG;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
private enum State {
  Init;      // 初期化
  Main;      // メイン
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static var RET_MOVE_LEVEL:Int = 4; // レベル移動

  var _state:State;
  var _bDead:Bool = false;
  var _bMoveLevel:Bool = false;
  var _player:Player;
  var _field:FlxTilemap;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, field:FlxTilemap) {

    _player = player;
    _field = field;

    _state  = State.Init;
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;

    switch(_state) {
      case State.Init:
        // 初期化
        _state = State.Main;
      case State.Main:
        // メイン
        _updateMain();
    }

    if(_bDead) {
      // プレイヤー死亡
      return RET_DEAD;
    }
    if(_bMoveLevel) {
      // レベル移動
      return RET_MOVE_LEVEL;
    }

    return ret;
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {
    FlxG.collide(_player, _field);

    // 別のレベルへ移動するかどうかをチェック
    var dir = _checkMoveLevel();
    if(dir != Dir.None) {
      // レベル移動する
      if(_moveLevel(dir)) {
        // レベル移動できた
        _bMoveLevel = true;
      }
    }
  }

  /**
   * 別のレベルへ移動するかどうかチェック
   **/
  function _checkMoveLevel():Dir {
    var x1 = _player.left;
    var y1 = _player.top;
    var x2 = _player.right;
    var y2 = _player.bottom;

    var gs = Field.GRID_SIZE;
    if(x2 < gs) {
      Global.setStartPosition(FlxG.width-gs, y1);
      return Dir.Left; // 左のマップへ移動
    }
    if(y2 < gs) {
      Global.setStartPosition(x1, FlxG.height-gs);
      return Dir.Up; // 上のマップへ移動
    }
    if(x1 > FlxG.width-gs) {
      Global.setStartPosition(0, y1);
      return Dir.Right; // 右のマップへ移動
    }
    if(y1 > FlxG.height-gs) {
      Global.setStartPosition(x1, 0);
      return Dir.Down; // 下のマップへ移動
    }

    // 移動しない
    return Dir.None;
  }

  /**
   * 別のレベルへ移動する
   **/
  function _moveLevel(dir:Dir):Bool {

    var levelWidth:Int = 4;
    var levelHeight:Int = 4;


    var now:Int = Global.level-1;
    var next:Int = -1;
    switch(dir) {
      case Dir.Left:
        if(now%levelWidth == 0) {
          // 移動不可
          return false;
        }
        next = now - 1;
      case Dir.Up:
        if(now < levelWidth) {
          // 移動不可
          return false;
        }
        next = now - levelWidth;
      case Dir.Right:
        if(now%levelWidth == levelWidth-1) {
          // 移動不可
          return false;
        }
        next = now + 1;
      case Dir.Down:
        if(now/levelWidth >= levelHeight-1) {
          // 移動不可
          return false;
        }
        next = now + levelWidth;
      default:
        // あり得ない
        throw 'Error: Invalid dir = ${dir}';
    }

    // 移動可能
    Global.setLevel(next+1);
    return true;
  }
}
