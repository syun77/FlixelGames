package jp_2dgames.game.token;

import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.Particle;
import nape.callbacks.CbType;
import flixel.text.FlxText;
import jp_2dgames.lib.MyMath;
import flixel.addons.effects.FlxTrail;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;

/**
 * ボール
 **/
class Ball extends FlxNapeSprite {

  // 衝突コールバックタイプ
  public static var CB_BALL:CbType = null;

  // サイズ
  static inline var RADIUS:Float = 8.0;
  // 番号文字の描画オフセット
  static inline var TXT_OFS_X = 4;
  static inline var TXT_OFS_Y = 2;

  public static var parent:FlxTypedGroup<Ball> = null;
  /**
   * 生成
   **/
  public static function createParent(state:FlxNapeState):Void {
    CB_BALL = new CbType();
    parent = new FlxTypedGroup<Ball>(9);
    for(i in 0...parent.maxSize) {
      var ball = new Ball();
      state.add(ball.trail);
      parent.add(ball);
    }
    state.add(parent);
    for(ball in parent.members) {
      state.add(ball.txt);
    }
  }
  /**
   * 破棄
   **/
  public static function destroyParent():Void {
    CB_BALL = null;
    parent = null;
  }

  /**
   * 追加
   **/
  public static function add(number:Int, X:Float, Y:Float):Ball {
    var ball:Ball = parent.recycle();
    ball.init(number, X, Y);
    return ball;
  }

  /**
   * すべて停止しているかどうか
   **/
  public static function isSleepingAll():Bool {
    var b = true;
    parent.forEachAlive(function(ball:Ball) {
      if(ball.isSleeping == false) {
        b = false;
      }
    });
    return b;
  }

  /**
   * 存在するボールの数値の合計を求める
   * 「0」の場合はプレイヤー以外のボールがないのでゲームクリアとなる
   **/
  public static function countNumber():Int {
    var ret:Int = 0;
    parent.forEachAlive(function(ball:Ball) {
      ret += ball.number;
    });
    return ret;
  }

  /**
   * 最小の番号を取得する
   **/
  public static function getMinimumNumber():Int {
    var ret = 10;
    parent.forEachAlive(function(ball:Ball) {
      if(ball.number == 0) {
        // 0は飛ばす
        return;
      }
      if(ball.number < ret) {
        // 最小値更新
        ret = ball.number;
      }
    });
    return ret;
  }

  public static function setTarget(number:Int):Void {
    parent.forEachAlive(function(ball:Ball) {
      if(ball.number == number) {
        ball._bTarget = true;
      }
      else {
        ball._bTarget = false;
      }
    });
  }

  // ------------------------------------------------------------
  // ■フィールド
  var _number:Int;
  public var number(get, never):Int;
  var _trail:FlxTrail;
  var trail(get, never):FlxTrail;
  var _txt:FlxText;
  var txt(get, never):FlxText;
  var _bSleeping:Bool;
  var isSleeping(get, never):Bool;
  public var xcenter(get, never):Float;
  public var ycenter(get, never):Float;
  var _bTarget:Bool;
  public var isTarget(get, never):Bool;

  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    loadGraphic(AssetPaths.IMAGE_BALL, true);
    _registerAnim();
    createCircularBody(RADIUS);

    _timer = 0;

    var elasticity = 1; // 弾力性
    var friction = 2; // 摩擦係数
    setBodyMaterial(elasticity, friction, friction, 1, friction);
    var drag = 0.99; // 移動摩擦係数
    setDrag(drag, 0.5);

    _trail = new FlxTrail(this);
    _txt = new FlxText();
    _txt.setBorderStyle(FlxText.BORDER_OUTLINE_FAST);

    body.cbTypes.add(CB_BALL);

    body.userData.data = this;

    kill();
  }

  /**
   * 初期化
   **/
  public function init(number:Int, X:Float, Y:Float):Void {
    _number = number;
    x = X;
    y = Y;
    body.position.setxy(X, Y);

    animation.play('${number}');
    _bSleeping = true;

    if(_number > 0) {
      _txt.revive();
      _txt.text = '${_number}';
    }

    _trail.revive();

    Particle.start(PType.Ring, xcenter-8, ycenter-8, _toColor());
  }

  /**
   * 消滅 (演出あり)
   **/
  public function vanish():Void {

    Particle.start(PType.Circle, xcenter-8, ycenter-8, _toColor());
    Particle.start(PType.Ring, xcenter-8, ycenter-8, _toColor());

    if(_number == 0) {
      // プレイヤー死亡
      Snd.playSe("explosion");
      FlxG.camera.shake(0.05, 0.4);
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
    }
    else {
      Snd.playSe("damage");
      FlxG.camera.shake(0.01, 0.2);
    }

    kill();
  }

  /**
   * 座標を設定する
   **/
  override public function setPosition(X:Float = 0.0, Y:Float = 0.0):Void {
    body.position.setxy(X, Y);
    super.setPosition(X, Y);
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _trail.kill();
    _txt.kill();
    super.kill();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _timer++;

    if(_bTarget) {
      if(_timer%30 == 0) {
        Particle.start(PType.Ring, xcenter, ycenter, _toColor());
      }
    }

    if(body.velocity.length < 5) {
      body.velocity.setxy(0, 0);
      _bSleeping = true;
    }
    else {
      _bSleeping = false;
    }

    _txt.x = x + TXT_OFS_X;
    _txt.y = y + TXT_OFS_Y;
  }

  /**
   * 速度を設定 (同時に停止しているフラグを下げる)
   **/
  public function setVelocy(deg:Float, speed:Float):Void {
    body.velocity.x = speed * MyMath.cosEx(deg);
    body.velocity.y = speed * -MyMath.sinEx(deg);

    // 停止しているフラグを下げる
    _bSleeping = false;
  }

  function get_number() {
    return _number;
  }
  function get_trail() {
    return _trail;
  }
  function get_isSleeping() {
    return _bSleeping;
  }
  function get_txt() {
    return _txt;
  }
  function get_xcenter() {
    return x + origin.x;
  }
  function get_ycenter() {
    return y + origin.y;
  }
  function get_isTarget() {
    return _bTarget;
  }

  function _toColor():Int {
    switch(_number) {
      case 0: return FlxColor.WHITE; // プレイヤー
      case 1: return FlxColor.YELLOW; // 黄色
      case 2: return FlxColor.CYAN;
      case 3: return FlxColor.SALMON;
      case 4: return FlxColor.FUCHSIA;
      case 5: return FlxColor.CORAL;
      case 6: return FlxColor.LIME;
      case 7: return FlxColor.BROWN;
      case 8: return FlxColor.GRAY;
      default:
        return FlxColor.WHITE;
    }
  }

  function _registerAnim():Void {
    for(i in 0...9) {
      animation.add('${i}', [i], 1);
    }
  }
}
