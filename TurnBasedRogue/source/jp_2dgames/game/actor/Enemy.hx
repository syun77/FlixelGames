package jp_2dgames.game.actor;

import jp_2dgames.lib.DirUtil;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import jp_2dgames.game.actor.Actor;

/**
 * 敵
 **/
class Enemy extends Actor {

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(eid:Int, i:Int, j:Int, dir:Dir, ?params:Params):Enemy {
    var e = parent.recycle(Enemy);
    e.init(eid, i, j, dir, params);

    return e;
  }
  public static function forEachAlive(func:Enemy->Void):Void {
    parent.forEachAlive(func);
  }

  // -------------------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_ENEMY, true, 32, 32);
    _registerAnim();
  }

  /**
   * 初期化
   **/
  public function init(eid:Int, i:Int, j:Int, dir:Dir, ?param:Params):Void {
    _xnext = i;
    _ynext = j;
    _setPositionNext();

    _params = new Params();
    if(params != null) {
      // パラメータ指定あり
      _params.copyFromDynamic(params);
    }
    ID = eid;
    _dir = dir;
    _changeAnim();
  }


  /**
   * アニメ変更
   **/
  function _changeAnim():Void {
    animation.play('${ID}');
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    for(i in 0...5) {
      var v = i * 4;
      animation.add('${i+1}', [v, v+1], 4);
    }
  }
}
