package jp_2dgames.game.token;

import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import jp_2dgames.lib.Input;
import jp_2dgames.lib.DirUtil;

/**
 * プレイヤー
 **/
class Player extends Token {

  static inline var MOVE_SPEED:Float = 50.0;
  static inline var SHOT_SPEED:Float = 80.0;
  static inline var TIMER_SHOT:Float = 1.0; // 1秒
  static inline var TIMER_REVIVE:Float = 2.0; //

  var _cursor:Cursor;
  var _infantry:Infantry;
  var _view:RangeOfView;
  var _dir:Dir;
  var _tShot:Float;
  var _tRevive:Float;
  var _tAnim:Int;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, cursor:Cursor, view:RangeOfView) {
    super(X, Y, AssetPaths.IMAGE_PLAYER);
    _cursor = cursor;
    _view = view;
    _dir = Dir.Down;
    _tShot = 0;
    _tRevive = 1;
    visible = false;
    _cursor.visible = false;
    _tAnim = 0;
  }


  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 復活チェック
    if(_checkRevive(elapsed)) {
      // 復活待ち
      return;
    }

    _tAnim++;
    if(_tAnim%30 == 0) {
      Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
    }

    // 移動
    _move();

    // カーソル座標を設定
    _setCursorPosition();

    // ショット
    _tShot -= elapsed;
    _shot();

    // 砲台配置
    _putInfantry();
  }

  /**
   * ダメージ処理
   **/
  public function damage():Void {
    visible = false;
    _cursor.visible = false;
    _tRevive = TIMER_REVIVE;
    FlxG.camera.shake(0.01, 0.2);
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.WHITE);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.WHITE);
  }

  /**
   * 復活チェック
   **/
  function _checkRevive(elapsed:Float):Bool {
    if(_tRevive > 0) {
      // 復活待ち
      _tRevive -= elapsed;
      if(_tRevive <= 0) {
        // 復活
        visible = true;
        _cursor.visible = true;
        var pt = Field.getFlagPosition();
        pt.x /= 2;
        pt.y /= 2;
        x = pt.x;
        y = pt.y;
        pt.put();
      }
      return true;
    }

    return false;
  }

  /**
   * 移動
   **/
  function _move():Void {

    var s = Field.GRID_SIZE;
    if(x < s) {
      x = s;
    }
    if(y < s) {
      y = s;
    }
    if(x > FlxG.width-width-s) {
      x = FlxG.width-width-s;
    }
    if(y > FlxG.height-height-s) {
      y = FlxG.height-height-s;
    }

    var dir = DirUtil.getInputDirection();
    if(dir != Dir.None) {
      _dir = dir;
    }

    var deg = DirUtil.getInputAngle();
    if(deg == -1000) {
      velocity.set();
      return;
    }

    setVelocity(deg, MOVE_SPEED);
  }

  /**
   * カーソル座標を設定
   **/
  function _setCursorPosition():Void {

    var pt = DirUtil.getVector(_dir);
    var px = xcenter + pt.x * Field.GRID_SIZE;
    var py = ycenter + pt.y * Field.GRID_SIZE;
    _cursor.setPosition(px, py);
  }

  /**
   * ショット
   **/
  function _shot():Void {
    if(_tShot > 0) {
      // 撃てない
      return;
    }

    if(Input.press.B) {
      // 弾を撃つ
      var deg = DirUtil.toAngle(_dir);
      Shot.add(xcenter, ycenter, deg, SHOT_SPEED);
      _tShot = TIMER_SHOT;
    }
  }

  /**
   * 砲台配置
   **/
  function _putInfantry():Void {
    if(Input.press.X) {
      if(_cursor.enable) {
        var px = _cursor.x;
        var py = _cursor.y;
        Infantry.add(px, py);
      }
    }

    _infantry = Infantry.getFromPosition(_cursor.x, _cursor.y);
    if(_infantry != null) {
      if(Input.press.X) {
        _view.updateView(_cursor, _infantry.range);
      }
      _view.setPos(_cursor);
    }
    else {
      _view.hide();
    }
  }
}
