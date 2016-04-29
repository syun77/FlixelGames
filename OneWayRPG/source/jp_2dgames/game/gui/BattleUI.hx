package jp_2dgames.game.gui;

import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
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
  public static function setButtonCB(name:String, func:Void->Void):Void {
    _instance._setButtonCB(name, func);
  }
  public static function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    if(_instance != null) {
      _instance._getEvent(id, sender, data, params);
    }
  }

  // -------------------------------------------------
  // ■フィールド
  var _ui:FlxUI;
  var _txtHp:FlxUIText;      // プレイヤーのHP
  var _txtHpEnemy:FlxUIText; // 敵のHP
  var _txtFood:FlxUIText;    // 食糧
  var _buttonTbl:Map<String, Void->Void>;

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
        case "txtfood":
          _txtFood = cast widget;
      }
    });

    _buttonTbl = new Map<String, Void->Void>();
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
    // 食糧更新
    _txtFood.text = '${player.food}';
  }

  /**
   * ボタンのコールバックを設定
   **/
  function _setButtonCB(name:String, func:Void->Void):Void {
    _buttonTbl[name] = func;
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  function _getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {

    var widget:IFlxUIWidget = cast sender;
    if(widget != null && Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          // ボタンパラメータを判定
          if(fuib.params != null) {
            var key = fuib.params[0];
            if(_buttonTbl.exists(key)) {
              _buttonTbl[key]();
            }
          }
      }
    }
  }
}
