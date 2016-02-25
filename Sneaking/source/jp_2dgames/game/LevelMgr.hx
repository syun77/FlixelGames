package jp_2dgames.game;
import flixel.FlxG;
import flixel.util.FlxRandom;
import jp_2dgames.game.token.ScrollObj;
import flixel.FlxBasic;

/**
 * レベル管理
 **/
class LevelMgr extends FlxBasic {

  // スクロール用のオブジェクト
  var _scrollObj:ScrollObj;
  // 前回マップを生成した座標
  var _yprevmap:Float;

  /**
   * コンストラクタ
   **/
  public function new(scrollObj:ScrollObj) {
    super();
    _scrollObj = scrollObj;
//    _scrollObj.y = -200;
    _scrollObj.setSpeed(100);

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
