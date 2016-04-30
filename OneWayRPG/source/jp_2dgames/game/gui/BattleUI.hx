package jp_2dgames.game.gui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import jp_2dgames.game.actor.ActorMgr;
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
  public static function setButtonClickCB(func:String->Void):Void {
    _instance._setButtonClickCB(func);
  }
  public static function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    if(_instance != null) {
      _instance._getEvent(id, sender, data, params);
    }
  }
  public static function setButtonLabel(group:String, name:String, label:String):Void {
    _instance._setButtonLabel(group, name, label);
  }
  public static function setVisibleItem(group:String, name:String, b:Bool):Void {
    _instance._setVisibleItem(group, name, b);
  }
  /**
   * 指定グループの表示・非表示を切り替える
   **/
  public static function setVisibleGroup(key:String, b:Bool):Void {
    _instance._setVisibleGroup(key, b);
  }

  /**
   * ボタンを押せないようにする
   **/
  public static function lockButton(group:String, name:String):Void {
    _instance._lockButton(group, name);
  }

  // -------------------------------------------------
  // ■フィールド
  var _tAnim:Int = 0; // アニメーション用タイマー
  var _ui:FlxUI;
  var _txtHp:FlxUIText;      // プレイヤーのHP
  var _txtHpEnemy:FlxUIText; // 敵のHP
  var _txtFood:FlxUIText;    // 食糧
  var _buttonTbl:Map<String, Void->Void>;
  var _buttonClickCB:String->Void = null;

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

    // 不要なUIを消しておく
    _setVisibleGroup("field", false);
    _setVisibleGroup("inventory", false);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

    // HP更新
    _updateHp();
  }

  /**
   * HP更新
   **/
  function _updateHp():Void {
    var player = ActorMgr.getPlayer();
    var enemy = ActorMgr.getEnemy();

    // HP更新
    _txtHp.text = '${player.hp}/${player.hpmax}';
    _txtHpEnemy.text = '${enemy.hp}';

    _txtHp.color = _getHpTextColor(player);
    _txtHpEnemy.color = _getHpTextColor(enemy);

    // 食糧更新
    _txtFood.text = '${player.food}';
    _txtFood.color = _getFoodTextColor(player);
  }

  /**
   * HPテキストの色を取得する
   **/
  function _getHpTextColor(actor:Actor):Int {

    if(_tAnim%60 < 30) {
      return FlxColor.WHITE;
    }

    if(actor.isDanger()) {
      return FlxColor.RED;
    }
    if(actor.isWarning()) {
      return FlxColor.YELLOW;
    }

    return FlxColor.WHITE;
  }

  /**
   * 食糧のテキストの色を取得する
   **/
  function _getFoodTextColor(actor:Actor):Int {

    if(_tAnim%60 < 30) {
      return FlxColor.WHITE;
    }

    if(actor.food <= 3) {
      return FlxColor.RED;
    }

    return FlxColor.WHITE;
  }

  /**
   * 指定のボタンのラベル変更
   **/
  function _setButtonLabel(key:String, name:String, label:String):Void {
    var group = _ui.getGroup(key);
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(Std.is(widget, FlxUIButton)) {
        var btn:FlxUIButton = cast widget;
        if(btn.name == name) {
          btn.label.text = label;
        }
      }
    });
  }

  /**
   * 指定の項目の表示・非表示
   **/
  function _setVisibleItem(key:String, name:String, b:Bool):Void {
    var group = _ui.getGroup(key);
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(widget.name == name) {
        widget.visible = b;
      }
    });
  }

  /**
   * 指定グループの表示・非表示
   **/
  function _setVisibleGroup(key:String, b:Bool):Void {
    var group = _ui.getGroup(key);
    group.visible = b;
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(Std.is(widget, FlxUIButton)) {
        var btn:FlxUIButton = cast widget;
        // ロックされていたら解除
        btn.skipButtonUpdate = false;
        btn.color = FlxColor.WHITE;
        btn.label.color = FlxColor.WHITE;
      }
    });
  }

  /**
   * ボタンを押せないようにする
   **/
  function _lockButton(group:String, name:String):Void {
    var group = _ui.getGroup(group);
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(widget.name != name) {
        return;
      }
      if(Std.is(widget, FlxUIButton)) {
        var btn:FlxUIButton = cast widget;
        if(btn.name == name) {
          btn.skipButtonUpdate = true;
          btn.color = FlxColor.GRAY;
          btn.label.color = FlxColor.GRAY;
        }
      }
    });
  }

  /**
   * ボタンのコールバックを設定
   **/
  function _setButtonCB(name:String, func:Void->Void):Void {
    _buttonTbl[name] = func;
  }
  function _setButtonClickCB(func:String->Void):Void {
    _buttonClickCB = func;
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
            // ボタン名を送信
            if(_buttonClickCB != null) {
              _buttonClickCB(key);
            }
          }
      }
    }
  }
}
