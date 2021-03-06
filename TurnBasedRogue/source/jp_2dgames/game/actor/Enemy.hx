package jp_2dgames.game.actor;

import jp_2dgames.lib.Snd;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import jp_2dgames.game.token.Bullet;
import jp_2dgames.game.actor.EnemyInfo.EnemyAI;
import jp_2dgames.game.token.TokenMgr;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.math.FlxPoint;
import jp_2dgames.lib.DirUtil;
import flixel.FlxState;
import jp_2dgames.game.actor.Actor;

/**
 * 敵
 **/
class Enemy extends Actor {

  public static var target(get, never):Player;
  public static var parent:TokenMgr<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr<Enemy>(32, Enemy);
    state.add(parent);
    for(e in parent.members) {
      state.add(e.balloon);
    }
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(i:Int, j:Int, dir:Dir, prms:Params):Enemy {
    var e:Enemy = parent.recycle();
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
    kill();
  }

  /**
   * 初期化
   **/
  override public function init(i:Int, j:Int, dir:Dir, ?prms:Params):Void {
    super.init(i, j, dir, prms);
    ID = prms.id;
    _changeAnim();

    // 出現時は眠っている
    changeBadStatus(BadStatus.Sleep);
//    changeBadStatus(BadStatus.Slow);
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
    var dir = Dir.None;
    if(EnemyInfo.getAI(ID) == EnemyAI.Stay) {
      // 動かない
      return  Dir.None;
    }
    if(EnemyInfo.getAI(ID) == EnemyAI.AStar) {
      // A*で移動経路を求める
      dir = _aiMoveDirAStar();
    }
    if(dir == Dir.None) {
      // 頭の悪い方法で移動
      dir = _aiMoveDirStupid();
    }

    return dir;
  }

  /**
   * 移動できるかどうか
   **/
  function _isMove(px:Int, py:Int):Bool {

    if(EnemyInfo.getFly(ID) != EnemyInfo.EnemyFly.Wall) {
      // 壁抜け属性がなければ壁とのヒットチェック
      if(Field.isCollide(px, py)) {
        return false;
      }
    }

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
      switch(_badstatus) {
        case BadStatus.Sleep: return false; // 眠っている
        case BadStatus.Paralysis: return false; // 麻痺している
        case BadStatus.Slow:
          return if(_params.badstatus_turn%2 == 1) true else false; // 移動力低下
        default:
          if(_state == Actor.State.TurnEnd) {
            // ターン終了している
            return false;
          }
          return true;
      }
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

    // 弾が撃てるかどうか
    if(_checkShot()) {
      return true;
    }

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
   * 弾が撃てるかどうか
   **/
  function _checkShot():Bool {
    if(EnemyInfo.getExtra(ID) == "bullet") {
      // 弾が撃てる
      var dx = target.xchip - xchip;
      var dy = target.ychip - ychip;
      if(dx == 0 || dy == 0) {
        // 軸が合っている
        dx = if(dx != 0) FlxMath.signOf(dx) else 0;
        dy = if(dy != 0) FlxMath.signOf(dy) else 0;
        var px = xchip + dx;
        var py = ychip + dy;
        var bHit = false;
        for(i in 0...16) {
          if(Field.isCollide(px, py)) {
            // 壁がある
            bHit = true;
            break;
          }
          if(Enemy.getFromPosition(px, py) != null) {
            // 別の敵がいる
            bHit = true;
            break;
          }
          px += dx;
          py += dy;
          if(px == target.xchip && py == target.ychip) {
            break;
          }
        }
        if(bHit == false) {
          // 障害物がない
          return true;
        }
      }
    }

    return false;
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
      if(_checkShot()) {
        // 弾を撃つ
        var dx = target.xchip - xchip;
        var dy = target.ychip - ychip;
        var type = BulletType.Horizon;
        if(dx == 0) {
          type = BulletType.Vertical;
        }
        Bullet.add(type, xchip, ychip);
        // 攻撃開始の処理
        target.damage(1);
        new FlxTimer().start(0.5, function(timer:FlxTimer) {
          // 消滅時に行動終了にする
          _cbActionEnd();
        });
        super.beginAction();
        return;
      }

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

    var prev = badstatus;
    super.turnEnd();

    switch(EnemyInfo.getExtra(ID)) {
      case "sleep":
        if(prev == BadStatus.None) {
          // ターン終了後に眠る
          changeBadStatus(BadStatus.Sleep);
        }
    }

  }

  /**
   * ダメージ
   **/
  override public function damage(val:Int):Void {
    _params.hp -= val;
    if(_params.hp <= 0) {
      // 倒した
      _params.hp = 0;
      FlxG.camera.shake(0.01, 0.2);
      Particle.start(PType.Ring2, xcenter, ycenter, FlxColor.RED);
      Snd.playSe("destroy", true);
      kill();
      // ターン回復
      SeqMgr.recoverTurn(Consts.RECOVER_ENEMY_KILL);
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
