package jp_2dgames.game;
import jp_2dgames.game.actor.ActorMgr;
import flixel.FlxState;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.TextUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 明るさモード
 **/
private enum Mode {
  Brighten; // 明るくする
  Darken;   // 暗くする
}

/**
 * 背景
 **/
class Bg extends FlxSprite {

  static inline var ALPHA_BASE:Float = 0.7;

  static var _instance:Bg = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new Bg();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }

  // 暗くする
  public static function darken():Void {
    _instance._darken();
  }
  // 明るくする
  public static function brighten():Void {
    _instance._brighten();
  }

  // --------------------------------------
  // ■フィールド
  var _mode:Mode = Mode.Brighten;

  /**
   * コンストラクタ
   **/
  private function new() {
    super();
    // 背景画像読み込み
    var name = TextUtil.fillZero(Global.level, 3);
    loadGraphic('assets/images/bg/${name}.jpg');
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 明るさモード更新
    _updateMode(elapsed);

    // 危険状態更新
    _updateDanger(elapsed);
  }

  /**
   * 明るさモード更新
   **/
  function _updateMode(elapsed:Float):Void {

    var speed:Float = 3;
    y = -80 * (1 - alpha) / 0.5;

    switch(_mode) {
      case Mode.Brighten:
        alpha += (1 - alpha) * speed * elapsed;
      case Mode.Darken:
        alpha += (ALPHA_BASE - alpha) * speed * elapsed;
    }
  }

  /**
   * 危険モード更新
   **/
  function _updateDanger(elapsed:Float):Void {

    var player = ActorMgr.getPlayer();
    if(player == null) {
      return;
    }
    var c1 = color;
    var c2 = FlxColor.WHITE;
    if(player.isDanger()) {
      // 危険状態
      c2 = FlxColor.RED;
    }
    else if(player.isWarning()) {
      // 警告状態
    c2 = FlxColor.YELLOW;
    }

    color = FlxColor.interpolate(c1, c2, 0.1);
  }


  function _darken():Void {
    _mode = Mode.Darken;
  }
  function _brighten():Void {
    _mode = Mode.Brighten;
  }
}
