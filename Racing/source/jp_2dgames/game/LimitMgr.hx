package jp_2dgames.game;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxBasic;

/**
 * 制限時間管理
 **/
class LimitMgr extends FlxBasic {

  private static var _instance:LimitMgr = null;
  // 生成
  public static function create(state:FlxState):Void {
    _instance = new LimitMgr();
    state.add(_instance);
  }
  // 破棄
  public static function terminate(state:FlxState):Void {
    state.remove(_instance);
    _instance = null;
  }

  public static function set(v:Float):Void {
    _instance._set(v);
  }
  public static function get():Float {
    return _instance._get();
  }
  public static function add(v:Float):Void {
    _instance._add(v);
  }
  public static function reduce(v:Float):Void {
    _instance._reduce(v);
  }
  public static function pause():Void {
    _instance.active = false;
  }
  public static function resume():Void {
    _instance.active = true;
  }
  public static function timesup():Bool {
    return _instance._timesup();
  }
  public static function isDanger():Bool {
    return _instance._isDanger();
  }

  var _time:Float = 0;
  var _bPause:Bool = false;

  public function new() {
    super();

    // TODO: データに逃がす
    _time = (2 * 60) + 10;
  }

  private function _set(v:Float):Void {
    _time = v;
  }
  private function _get():Float {
    return _time;
  }
  private function _add(v:Float):Void {
    _time += v;
  }
  private function _reduce(v:Float):Void {
    _time -= v;
    if(_time <= 0) {
      _time = 0;
    }
  }
  private function _timesup():Bool {
    return _time <= 0;
  }
  private function _isDanger():Bool {
    return _time < 10;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // 時間経過
    _reduce(FlxG.elapsed);
  }
}
