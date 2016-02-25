package jp_2dgames.game.token;

import flixel.util.FlxAngle;
import flixel.ui.FlxAnalog;
import jp_2dgames.lib.MyMath;
import flixel.util.FlxPoint;
import flash.display.BlendMode;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import jp_2dgames.game.particle.Particle;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * 敵
 **/
class Enemy extends Token {

  // 視界
  static inline var VIEW_DISTANCE:Float = 200.0;

  public static var parent:FlxTypedGroup<Enemy> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Enemy>(16);
    for(i in 0...parent.maxSize) {
      var e = new Enemy();
      parent.add(e);
      state.add(e._view);
    }
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Enemy {
    var enemy:Enemy = parent.recycle();
    enemy.init(X, Y);
    return enemy;
  }

  static var _target:Player = null;
  public static function setTarget(player:Player):Void {
    _target = player;
  }

  // ------------------------------------------------
  // ■フィールド
  // 視界の距離
  var _viewDistance:Float = VIEW_DISTANCE;
  // 視野角
  var _viewAngle:Float = 30.0;
  // 視界
  var _view:FlxSprite;
  // 向いている方向
  var _direction:Float;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PERSON);
    color = FlxColor.LIME;

    _view = new FlxSprite();
    _view.makeGraphic(400, 400, FlxColor.TRANSPARENT);
    _view.alpha = 0.2;
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;

    // 下向き
    _direction = -90;

    // 視界の作成
    _createView();

    _updateView();
  }

  /**
   * 消滅
   **/
  override public function kill():Void {
    _view.kill();
    super.kill();
  }

  /**
   * 消滅
   **/
  public function vanihs():Void {
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.LIME);
    kill();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
    _updateView();

    if(_findTarget()) {
      // プレイヤー発見
      color = FlxColor.RED;
    }
    else {
      color = FlxColor.LIME;
    }

  }

  /**
   * 視野の作成
   **/
  function _createView():Void {
    // 視野角度
    var deg:Float = _viewAngle;
    _view.revive();
    var array = new Array<FlxPoint>();
    var px:Float = _view.width/2;  // 中心(X)
    var py:Float = _view.height/2; // 中心(Y)
    var x1 = px + _viewDistance * MyMath.cosEx(deg);
    var y1 = py + _viewDistance * -MyMath.sinEx(deg);
    var x2 = px + _viewDistance * MyMath.cosEx(-deg);
    var y2 = py + _viewDistance * -MyMath.sinEx(-deg);
    array.push(FlxPoint.get(px, py));
    array.push(FlxPoint.get(x1, y1));
    array.push(FlxPoint.get(x2, y2));
    FlxSpriteUtil.fill(_view, FlxColor.TRANSPARENT);
    FlxSpriteUtil.drawPolygon(_view, array, FlxColor.WHITE);
    for(pt in array) {
      pt.put();
    }
  }

  /**
   * 視界の更新
   **/
  function _updateView():Void {
    _view.x = xcenter - _view.width/2;
    _view.y = ycenter - _view.height/2;

    // FlxSprite.angle は逆回り
    _view.angle = 360 - _direction;
    _direction += 1;
  }

  /**
   * プレイヤーを見つけたかどうか
   **/
  function _findTarget():Bool {
    if(FlxMath.isDistanceWithin(this, _target, _viewDistance) == false) {
      // 一定の距離内に存在しない
      return false;
    }

    if(MyMath.checkView(xcenter, ycenter, _direction, _viewDistance, _viewAngle, _target.xcenter, _target.ycenter) == false) {
      // 視界外
      return false;
    }

    // 視界内
    return true;
  }
}
