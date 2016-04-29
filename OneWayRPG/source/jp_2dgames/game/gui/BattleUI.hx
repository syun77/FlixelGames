package jp_2dgames.game.gui;

import flixel.math.FlxRect;
import flixel.FlxSprite;
import jp_2dgames.game.actor.ActorMgr;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUI;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI
 **/
class BattleUI extends FlxSpriteGroup {
  static var _instance:BattleUI = null;
  public static function createInstance(state:FlxState, ui:FlxUI):Void {
    _instance = new BattleUI(ui);
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function getPlayerHpRect():FlxRect {
    var rect = FlxRect.get();
    rect.x = _instance._txtHp.x;
    rect.y = _instance._txtHp.y;
    rect.width = _instance._txtHp.width;
    rect.height =_instance._txtHp.height;
    return rect;
  }

  // -------------------------------------------------
  // ■フィールド
  var _ui:FlxUI;
  var _txtHp:FlxUIText;
  var _txtHpEnemy:FlxUIText;

  /**
   * コンストラクタ
   **/
  public function new(ui:FlxUI):Void {
    super();
    _ui = ui;

    _ui.forEach(function(spr:FlxSprite) {
      var widget:IFlxUIWidget = cast spr;
      switch(widget.name) {
        case "txthp":
          _txtHp = cast widget;
        case "txtenemyhp":
          _txtHpEnemy = cast widget;
      }
    });
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    var player = ActorMgr.getPlayer();
    var enemy = ActorMgr.getEnemy();

    // HP更新
    _txtHp.text = '${player.hp}/${player.hpmax}';
    _txtHpEnemy.text = '${enemy.hp}';
  }

}
