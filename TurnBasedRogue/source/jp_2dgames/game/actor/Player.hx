package jp_2dgames.game.actor;

import jp_2dgames.game.state.BootState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.FlxG;
import openfl.display.BlendMode;
import jp_2dgames.lib.DirUtil;
import flixel.FlxSprite;

/**
 * 踏んでいるチップ
 **/
enum StompChip {
  None;  // 何もなし
  Stair; // 階段
}

/**
 * プレイヤー
 **/
class Player extends Actor {

  var _light:FlxSprite;
  public var light(get, never):FlxSprite;

  // 踏みつけているチップ
  var _stompChip:StompChip = StompChip.None;
  public var stompChip(get, never):StompChip;

  var _bWalk:Bool  = false;
  // 攻撃対象
  var _target:Enemy = null;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    _registerAnim();
    _playAnim();

    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);

    FlxG.watch.add(this, "_state", "Player.state");
    FlxG.watch.add(this, "_stateprev", "Player.stateprev");
    FlxG.watch.add(this, "x", "Player.x");
    FlxG.watch.add(this, "y", "Player.y");
  }

  /**
   * 初期化
   **/
  public function init(i:Int, j:Int, dir:Dir, ?params:Params):Void {
    _xnext = i;
    _ynext = j;
    _setPositionNext();
    _params = new Params();
    if(params != null) {
      // パラメータ指定あり
      _params.copyFromDynamic(params);
    }
    _dir = dir;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
    _playAnim();
    _updateLight();
  }

  /**
   * 手動更新
   **/
  override public function proc():Void {
    switch(_state) {
      case Actor.State.KeyInput:
        _procKeyInput();

      case Actor.State.ActBegin:
        // 何もしない

      case Actor.State.Act:
        // 何もしない

      case Actor.State.ActEnd:
        // 何もしない

      case Actor.State.MoveBegin:
        // 何もしない

      case Actor.State.Move:
        if(_procMove()) {
          // 移動完了
          _setStompChip();
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
   * 行動開始
   **/
  override public function beginAction():Void {

    if(_state == Actor.State.ActBegin) {
      // 攻撃アニメーション開始
      var x1 = x;
      var y1 = y;
      var x2 = Field.toWorldX(_target.xchip);
      var y2 = Field.toWorldY(_target.ychip);

      FlxTween.tween(this, {x:x2, y:y2}, 0.1, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
        // 敵にダメージ
        _target.damage(1);
        FlxTween.tween(this, {x:x1, y:y1}, 0.1, {ease:FlxEase.expoOut, onComplete:function(tween:FlxTween) {
          // 攻撃終了
          _change(Actor.State.TurnEnd);
        }});
      }});
    }

    super.beginAction();
  }

  /**
   * ターン終了
   **/
  override public function turnEnd():Void {
    super.turnEnd();
  }

  /**
   * 踏みつけているチップをリセットする
   **/
  public function endStompChip():Void {
    _stompChip = StompChip.None;
  }

  /**
   * 更新・待機中
   **/
  function _procKeyInput():Void {

    _bWalk = false;

    var dir = DirUtil.getInputDirection();
    if(dir == Dir.None) {
      // 移動しない
      return;
    }

    _dir = dir;
    var pt = FlxPoint.get(_xnow, _ynow);
    pt = DirUtil.move(_dir, pt);
    var px = Std.int(pt.x);
    var py = Std.int(pt.y);

    // 移動可能かどうかチェック
    if(Field.isCollide(px, py)) {
      // 移動できない
      return;
    }

    _target = null;
    Enemy.forEachAlive(function(e:Enemy) {
      if(e.existsPosition(px, py)) {
        // 敵がいた
        _target = e;
      }
    });

    // 移動先に敵がいれば攻撃
    if(_target != null) {
      _change(Actor.State.ActBegin);
      return;
    }

    // 移動する
    _xnext = px;
    _ynext = py;

    _change(Actor.State.MoveBegin);
    _bWalk = true;
  }

  /**
   * ダメージ
   **/
  override public function damage(val:Int):Void {
    _params.hp -= val;
    if(_params.hp < 0) {
      _params.hp = 0;
    }
    super.damage(val);
  }

  /**
   * 踏んでいるチップを設定する
   **/
  function _setStompChip():Void {
    switch(Field.getChip(xchip, ychip)) {
      case Field.CHIP_STAIR:
        // 階段
        _stompChip = StompChip.Stair;
      default:
        // それ以外は何もなし
        _stompChip = StompChip.None;
    }
  }

  /**
   * 明かりを更新
   **/
  function _updateLight():Void {
    var sc = FlxG.random.float(0.7, 1) * 2;
    _light.scale.set(sc, sc);
    _light.alpha = FlxG.random.float(0.2, 0.3);
    _light.x = xcenter;
    _light.y = ycenter;

  }

  /**
   * アニメーション再生
   **/
  function _playAnim():Void {
    animation.play('${_dir}${_bWalk}');
  }

  /**
   * アニメーションを登録
   **/
  function _registerAnim():Void {
    var spd:Int = 2;
    var bWalk:Bool = false;
    animation.add('${Dir.Left}${bWalk}', [0, 1], spd);
    animation.add('${Dir.Up}${bWalk}', [4, 5], spd);
    animation.add('${Dir.Right}${bWalk}', [8, 9], spd);
    animation.add('${Dir.Down}${bWalk}', [12, 13], spd);

    spd = 6;
    bWalk = true;
    animation.add('${Dir.Left}${bWalk}', [2, 3], spd);
    animation.add('${Dir.Up}${bWalk}', [6, 7], spd);
    animation.add('${Dir.Right}${bWalk}', [10, 11], spd);
    animation.add('${Dir.Down}${bWalk}', [14, 15], spd);
  }


  // ---------------------------------------------------
  // ■アクセサ
  function get_light() {
    return _light;
  }
  function get_stompChip() {
    return _stompChip;
  }
}
