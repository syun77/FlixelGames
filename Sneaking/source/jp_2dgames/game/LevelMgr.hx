package jp_2dgames.game;
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
  static inline var VIEW_DISTANCE_LAST:Float = 200.0;
  static inline var VIEW_RANGE_LAST:Float = 30.0;

  static var _viewRange:Float = 0.0;
  static var _viewDistance:Float = 0.0;
  public static function getViewRange() {
    return _viewRange;
  }
  public static function getViewDistance() {
    return _viewDistance;
  }

  // スクロール用のオブジェクト
  var _scrollObj:ScrollObj;
  // 前回マップを生成した座標
  var _yprevmap:Float;
  // フレームカウンタ
  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new(scrollObj:ScrollObj) {
    super();
    _scrollObj = scrollObj;
//    _scrollObj.y = -200;
    _scrollObj.setSpeed(50);

    _viewRange = VIEW_RANGE_FIRST;
    _viewDistance = VIEW_DISTANCE_FIRST;

    _createField();
  }

  /**
   * フィールドの生成
   **/
  function _createField():Void {
    var rnd = FlxRandom.intRanged(1, 3);
    Field.loadLevel(rnd);
    Field.createObjects(FlxG.camera.scroll.y);
    _yprevmap = FlxG.camera.scroll.y;

    trace("create new map:", rnd);
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

    FlxG.worldBounds.set(0, yoffset, FlxG.width, FlxG.height);
    Field.updateLayer(yoffset);

    _timer++;
    {
      var d = (VIEW_RANGE_LAST - VIEW_RANGE_FIRST);
      _viewRange = (MyMath.calcRank3MIN(_timer)-1) * d + VIEW_RANGE_FIRST;
    }
    {
      var d = (VIEW_DISTANCE_LAST - VIEW_DISTANCE_FIRST);
      _viewDistance = (MyMath.calcRank3MIN(_timer)-1) * d + VIEW_DISTANCE_FIRST;
    }
  }

  /**
   * 停止する
   **/
  public function stop():Void {
    // スクロール停止
    _scrollObj.drag.y = 50;
    active = false;
  }
}
