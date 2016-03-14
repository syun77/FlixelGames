package jp_2dgames.game.actor;

import jp_2dgames.game.token.Token;
import flixel.math.FlxPoint;
import flixel.FlxG;
import openfl.display.BlendMode;
import jp_2dgames.lib.DirUtil;
import flixel.FlxSprite;

/**
 * 状態
 **/
private enum State {
  Standby; // 待機中
  Walking; // 歩き中
}

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var TIMER_WALKING:Int = 12;

  var _light:FlxSprite;
  public var light(get, never):FlxSprite;

  var _dir:Dir     = Dir.Down;
  var _state:State = State.Standby;
  var _timer:Int   = 0;
  var _xprev:Int = 0;
  var _yprev:Int = 0;
  var _xnext:Int = 0;
  var _ynext:Int = 0;
  var _params:Params = null;
  public var dir(get, never):Dir;
  public var xchip(get, never):Int;
  public var ychip(get, never):Int;
  public var params(get, never):Params;

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
  public function proc():Void {
    switch(_state) {
      case State.Standby:
        _procStandby();
      case State.Walking:
        _procWalking();
    }
  }

  /**
   * 更新・待機中
   **/
  function _procStandby():Void {
    var dir = DirUtil.getInputDirection();
    if(dir == Dir.None) {
      // 移動しない
      return;
    }

    _dir = dir;
    var pt = FlxPoint.get(_xprev, _yprev);
    pt = DirUtil.move(_dir, pt);

    // 移動可能かどうかチェック
    if(Field.isCollide(pt.x, pt.y)) {
      // 移動できない
      return;
    }

    _xnext = Std.int(pt.x);
    _ynext = Std.int(pt.y);

    _state = State.Walking;
    _timer = 0;
  }

  /**
   * 更新・歩き中
   **/
  function _procWalking():Void {

    _timer++;
    var t = _timer / TIMER_WALKING;
    x = Field.toWorldX(_xprev) + (_xnext - _xprev) * Field.GRID_SIZE * t;
    y = Field.toWorldY(_yprev) + (_ynext - _yprev) * Field.GRID_SIZE * t;

    if(_timer >= TIMER_WALKING) {
      // 移動完了
      _setPositionNext();
      _state = State.Standby;
    }
  }

  /**
   * xnext / ynext に移動する
   **/
  function _setPositionNext():Void {
    x = Field.toWorldX(_xnext);
    y = Field.toWorldY(_ynext);
    _xprev = _xnext;
    _yprev = _ynext;
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
    var bWalk = (_state == State.Walking);
    animation.play('${_dir}${bWalk}');
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

  function get_xchip() {
    return _xnext;
  }
  function get_ychip() {
    return _ynext;
  }
  function get_params() {
    return _params;
  }
  function get_dir() {
    return _dir;
  }
}
