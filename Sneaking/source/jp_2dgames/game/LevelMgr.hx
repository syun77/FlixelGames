package jp_2dgames.game;
import jp_2dgames.game.token.Player;
import jp_2dgames.lib.MyMath;
import flixel.FlxG;
import flixel.util.FlxRandom;
import jp_2dgames.game.token.ScrollObj;
import flixel.FlxBasic;

/**
 * レベル管理
 **/
class LevelMgr extends FlxBasic {

  static inline var VIEW_DISTANCE_FIRST:Float = 100.0;
  static inline var VIEW_RANGE_FIRST:Float = 20.0;
  static inline var VIEW_DISTANCE_LAST:Float = 300.0;
  static inline var VIEW_RANGE_LAST:Float = 30.0;
  static inline var VIEW_ROLL_FIRST:Float = 1.0;
  static inline var VIEW_ROLL_LAST:Float = 3.0;

  static var _viewRange:Float = VIEW_RANGE_FIRST;
  static var _viewDistance:Float = VIEW_DISTANCE_FIRST;
  static var _viewRoll:Float = VIEW_ROLL_FIRST;
  public static function getViewRange() {
    return _viewRange;
  }
  public static function getViewDistance() {
    return _viewDistance;
  }
  public static function getViewRoll() {
    return _viewRoll;
  }

  // スクロール用のオブジェクト
  var _scrollObj:ScrollObj;
  // プレイヤー
  var _player:Player;
  // 前回マップを生成した座標
  var _yprevmap:Float;
  // フレームカウンタ
  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new(scrollObj:ScrollObj, player:Player) {
    super();
    _scrollObj = scrollObj;
//    _scrollObj.y = -200;
    _scrollObj.setSpeed(50);
    _player = player;

    _viewRange = VIEW_RANGE_FIRST;
    _viewDistance = VIEW_DISTANCE_FIRST;

    _createField();
  }

  /**
   * フィールドの生成
   **/
  function _createField():Void {
    var max = Std.int(3 + _timer/60/10);
    if(max > 10) {
      max = 10;
    }
    var rnd = FlxRandom.intRanged(1, max);
    Field.loadLevel(rnd);
    Field.createObjects(FlxG.camera.scroll.y);
    _yprevmap = FlxG.camera.scroll.y;

  }

  /**
   * 更新
   **/
  public function proc():Void {
    var yoffset = FlxG.camera.scroll.y;
    if(yoffset < _yprevmap - Field.getHeight()) {
      // 新しいマップ出現
      _createField();
    }

    FlxG.worldBounds.set(0, yoffset-FlxG.height*2, FlxG.width, FlxG.height*3);
    Field.updateLayer(yoffset);

    // プレイヤーの位置によってスクロール速度を変える
    {
      var d = Math.abs(FlxG.camera.scroll.y - _player.y);
      d /= FlxG.height;
      _scrollObj.setSpeed(150 + 50*d);
    }

    // 敵の視界範囲・距離更新
    _timer++;
    {
      var d = (VIEW_RANGE_LAST - VIEW_RANGE_FIRST);
      _viewRange = (MyMath.calcRank3MIN(_timer)-1) * d + VIEW_RANGE_FIRST;
    }
    {
      var d = (VIEW_DISTANCE_LAST - VIEW_DISTANCE_FIRST);
      _viewDistance = (MyMath.calcRank3MIN(_timer)-1) * d + VIEW_DISTANCE_FIRST;
    }
    // 視界の旋回速度
    {
      var d = (VIEW_ROLL_LAST - VIEW_ROLL_FIRST);
      _viewRoll = (MyMath.calcRank3MIN(_timer)-1) * d + VIEW_ROLL_FIRST;
    }
  }

  /**
   * 停止する
   **/
  public function stop(bForce:Bool):Void {
    // スクロール停止
    _scrollObj.drag.y = 50;
    active = false;
    if(bForce) {
      // スクロール強制停止
      _scrollObj.velocity.set();
    }
  }
}
