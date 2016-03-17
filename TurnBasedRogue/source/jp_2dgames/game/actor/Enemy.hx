package jp_2dgames.game.actor;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.math.FlxPoint;
import jp_2dgames.lib.DirUtil;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import jp_2dgames.game.actor.Actor;

/**
 * 敵
 **/
class Enemy extends Actor {

  public static var target(get, never):Player;
  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(i:Int, j:Int, dir:Dir, prms:Params):Enemy {
    var e = parent.recycle(Enemy);
    e.init(i, j, dir, prms);

    return e;
  }
  public static function forEachAlive(func:Enemy->Void):Void {
    parent.forEachAlive(func);
  }
  public static function getFromPosition(xc:Int, yc:Int):Enemy {
    var ret:Enemy = null;
    forEachAlive(function(e:Enemy) {
      if(e.existsPosition(xc, yc)) {
        ret = e;
      }
    });
    return ret;
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
  public function init(i:Int, j:Int, dir:Dir, prms:Params):Void {
    _xnext = i;
    _ynext = j;
    _setPositionNext();

    _params = new Params();
    _params.copyFromDynamic(prms);

    ID = params.id;
    _dir = dir;
    _changeAnim();

    FlxG.watch.add(this, "_state", "Enemy.state");
    FlxG.watch.add(this, "_stateprev", "Enemy.stateprev");
  }

  /**
	 * 更新
	 **/
  override public function proc():Void {

    switch(_state) {
      case Actor.State.KeyInput:
        // 何もしない

      case Actor.State.ActBegin:
        // 何もしない

      case Actor.State.Act:
        // Tweenアニメ中

      case Actor.State.ActEnd:
        // 何もしない

      case Actor.State.MoveBegin:
        // 何もしない

      case Actor.State.Move:
        if(_procMove()) {
          // 移動完了
          _setPositionNext();
          _change(Actor.State.TurnEnd);
        }

      case Actor.State.MoveEnd:
        // 何もしない

      case Actor.State.TurnEnd:
      // 何もしない
    }
  }

  /**
   * A*で移動経路を求める
   **/
  function _aiMoveDirAStar():Dir {
    // TODO: 未実装
    return Dir.None;
  }

  /**
   * 頭の悪い方法で移動
   **/
  function _aiMoveDirStupid():Dir {
    var target = cast(FlxG.state, PlayState).player;
    var dx = target.xchip - xchip;
    var dy = target.ychip - ychip;
    var func = function() {
      // 水平方向に移動するかどうか
      var bHorizon = Math.abs(dx) > Math.abs(dy);
      if(Math.abs(dx) == Math.abs(dy)) {
        // 距離が同じ場合はランダム
        bHorizon = FlxG.random.bool(50);
      }
      if(bHorizon) {
        return if(dx < 0) Dir.Left else Dir.Right;
      }
      else {
        return if(dy < 0) Dir.Up else Dir.Down;
      }
    };

    return func();
  }

  /**
   * 移動方向を決める
   **/
  function _aiMoveDir():Dir {
    // A*で移動経路を求める
    var dir = _aiMoveDirAStar();
    if(dir == Dir.None) {
      dir = _aiMoveDirStupid();
    }

    return dir;
  }

  /**
   * 移動できるかどうか
   **/
  function _isMove(px:Int, py:Int):Bool {
    var enemy = getFromPosition(px, py);
    if(enemy != null) {
      // 敵がいるので移動できない
      return false;
    }
    else {
      // 敵がいないので移動可能
      return true;
    }
  }

  public function requestMove():Void {
    // 行動可能かどうかチェック
    var checkActive = function() {
      if(_state == Actor.State.TurnEnd) {
        // ターン終了している
        return false;
      }
      return true;
    }

    if(checkActive() == false) {
      // 動けないのでターン終了
      standby();
      return;
    }

    // 攻撃可能かどうかチェック
    if(_checkAttack()) {
      // 攻撃する
      _change(Actor.State.ActBegin);
      return;
    }

    // 移動方向を決める
    var px = Std.int(_xnow);
    var py = Std.int(_ynow);
    var pt = FlxPoint.get(_xnow, _ynow);
    _dir = _aiMoveDir();
    pt = DirUtil.move(_dir, pt);
    px = Std.int(pt.x);
    py = Std.int(pt.y);
    pt.put();

    // 移動先にプレイヤーがいるかどうかをチェック
    if(target.existsPosition(px, py)) {
      // プレイヤーがいるので攻撃
      _change(Actor.State.ActBegin);
      return;
    }

    // 移動先チェック
    if(_isMove(px, py)) {
      // 移動可能
      _xnext = px;
      _ynext = py;
      _change(Actor.State.MoveBegin);
    }
    else {
      // 移動できないのでターン終了
      _change(Actor.State.TurnEnd);
    }
  }

  /**
   * 攻撃できるかどうか
   **/
  function _checkAttack():Bool {
    var bAttack = false;

    // 上下左右を調べる
    var pt = FlxPoint.get();
    for(dir in [Dir.Left, Dir.Up, Dir.Right, Dir.Down]) {
      pt.set(_xnow, _ynow);
      pt = DirUtil.move(dir, pt);
      if(target.existsPosition(Std.int(pt.x), Std.int(pt.y))) {
        // 近くにプレイヤーがいる
        // 攻撃できる
        _dir = dir;
        bAttack = true;
        break;
      }
    }

    return bAttack;
  }

  /**
   * アクション終了時に呼び出される関数
   **/
  function _cbActionEnd():Void {
    // 消滅時に行動終了する
    _change(Actor.State.TurnEnd);
  }

  /**
   * 攻撃開始
   **/
  override public function beginAction():Void {

    if(_state == Actor.State.ActBegin) {
      // 攻撃アニメーション開始
      /*
      if(_checkShot()) {
        // 弾を撃つ
        var itemid = _getCsvParamInt("firearm");
        var p = new ItemExtraParam();
        var item = new ItemData(itemid, p);
        var px = Field.toWorldX(xchip);
        var py = Field.toWorldY(ychip);
        var ms = MagicShot.start(px, py, this, target, item);
        ms.setEndCallback(function() {
          // 消滅時に行動終了にする
          _cbActionEnd();
        });
        super.beginAction();
        return;
      }
      */

      // 通常攻撃できるかどうか
      if(_checkAttack() == false) {
        // 攻撃できないので待機
        standby();
        return;
      }

      // 通常攻撃
      var x1:Float = x;
      var y1:Float = y;
      var x2:Float = target.x;
      var y2:Float = target.y;
      FlxTween.tween(this, {x:x2, y:y2}, 0.1, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
        // 攻撃開始の処理
        target.damage(1);
        FlxTween.tween(this, {x:x1, y:y1}, 0.1, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
          // 攻撃終了の処理
          _cbActionEnd();
        }});
      }});
    }

    super.beginAction();
  }

  /**
   * 移動開始
   **/
  override public function beginMove():Void {
    super.beginMove();
  }

  /**
   * ターン終了
   **/
  override public function turnEnd():Void {
    super.turnEnd();
  }

  /**
   * ダメージ
   **/
  override public function damage(val:Int):Void {
    _params.hp -= val;
    if(_params.hp <= 0) {
      _params.hp = 0;
      FlxG.camera.shake(0.01, 0.2);
      Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.RED);
      kill();
    }
    super.damage(val);
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

  // -----------------------------------------------
  // ■アクセサ
  static function get_target() {
    return cast(FlxG.state, PlayState).player;
  }
}
