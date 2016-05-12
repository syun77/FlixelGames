package jp_2dgames.game.gui;

import jp_2dgames.lib.StatusBar;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUISprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.item.ItemList;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUI;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * バトルUI起動パラメータ
 **/
class BattleUIParam {
  public var ui:FlxUI;
  public var hpbarPlayer:StatusBar;
  public var hpbarEnemy:StatusBar;

  public function new() {}
}

/**
 * バトルUI
 **/
class BattleUI extends FlxSpriteGroup {

  // ---------------------------------------------
  // ■定数
  static inline var HPBAR_PLAYER_OFS_X:Int = -8;
  static inline var HPBAR_PLAYER_OFS_Y:Int = 20;
  static inline var HPBAR_ENEMY_OFS_Y:Int = 20;

  static var _instance:BattleUI = null;
  public static function createInstance(state:FlxState, prm:BattleUIParam):Void {
    _instance = new BattleUI(prm);
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
  public static function getFoodPosition():FlxPoint {
    return _instance._getFoodPosition();
  }
  public static function setButtonCB(name:String, func:Void->Void):Void {
    _instance._setButtonCB(name, func);
  }
  public static function setButtonClickCB(func:String->Void):Void {
    _instance._setButtonClickCB(func);
  }
  public static function setButtonOverlapCB(func:String->Void):Void {
    _instance._setButtonOverlapCB(func);
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
    if(_instance == null) {
      return;
    }
    _instance._setVisibleGroup(key, b);
  }
  public static function setSpriteItem(group:String, name:String, path:String):Void {
    _instance._setSpriteItem(group, name, path);
  }
  public static function setTextItem(group:String, name:String, msg:String):Void {
    _instance._setTextItem(group, name, msg);
  }

  /**
   * ボタンを押せないようにする
   **/
  public static function lockButton(group:String, name:String):Void {
    _instance._lockButton(group, name);
  }

  public static function getResistIconName(idx:Int):String {
    return 'sprresist${idx}';
  }
  public static function getResistTextName(idx:Int):String {
    return 'txtresist${idx}';
  }

  /**
   * 強制的に外部から更新を行う
   **/
  public static function forceUpdate(elapsed:Float):Void {
    _instance.update(elapsed);
    _instance._hpbarPlayer.update(elapsed);
    _instance._hpbarEnemy.update(elapsed);
  }

  // -------------------------------------------------
  // ■フィールド
  var _tAnim:Int = 0; // アニメーション用タイマー
  var _ui:FlxUI;
  var _txtLevel:FlxUIText;    // フロア数
  var _txtSteps:FlxUIText;    // 残り歩数
  var _txtHp:FlxUIText;       // プレイヤーのHP
  var _txtStr:FlxUIText;      // プレイヤーのSTR
  var _txtDex:FlxUIText;      // プレイヤーのDEX
  var _txtAgi:FlxUIText;      // プレイヤーのAGI
  var _txtHpEnemy:FlxUIText;  // 敵のHP
  var _txtAtkEnemy:FlxUIText; // 敵の攻撃力
  var _txtFood:FlxUIText;     // 食糧
  var _txtMoney:FlxUIText;    // お金
  var _txtItem:FlxUIText;     // アイテム所持数
  var _hpbarPlayer:StatusBar; // HPゲージ (プレイヤー)
  var _hpbarEnemy:StatusBar;  // HPゲージ (敵)
  var _buttonTbl:Map<String, Void->Void>;
  var _buttonClickCB:String->Void = null;
  var _buttonOverlapCB:String->Void = null;

  /**
   * コンストラクタ
   **/
  public function new(prm:BattleUIParam):Void {
    super();
    _ui = prm.ui;
    _hpbarPlayer = prm.hpbarPlayer;
    _hpbarEnemy = prm.hpbarEnemy;

    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "txtlevel":
          _txtLevel = cast widget;
        case "txtsteps":
          _txtSteps = cast widget;
        case "txthp":
          _txtHp = cast widget;
        case "txtfood":
          _txtFood = cast widget;
        case "txtmoney":
          _txtMoney = cast widget;
        case "txtitem":
          _txtItem = cast widget;
        case "txtstr":
          _txtStr = cast widget;
        case "txtdex":
          _txtDex = cast widget;
        case "txtagi":
          _txtAgi = cast widget;
      }
    });
    {
      var grp = _ui.getGroup("enemyhud");
      grp.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
        switch(widget.name) {
          case "txtenemyhp":
            _txtHpEnemy = cast widget;
          case "txtenemyatk":
            _txtAtkEnemy = cast widget;
        }
      });
    }

    // HPゲージの座標を設定
    _hpbarPlayer.x = _txtHp.x+HPBAR_PLAYER_OFS_X;
    _hpbarPlayer.y = _txtHp.y+HPBAR_PLAYER_OFS_Y;
    _hpbarEnemy.x = _hpbarPlayer.x;
    _hpbarEnemy.y = _txtHpEnemy.y+HPBAR_ENEMY_OFS_Y;
    _hpbarEnemy.visible = false;

    _buttonTbl = new Map<String, Void->Void>();

    // 不要なUIを消しておく
    _setVisibleGroup("field", false);
    _setVisibleGroup("enemyhud", false);
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

    // フロア数更新
    _txtLevel.text = '${Global.level}F';

    // 残り歩数
    var steps = Global.step;
    _txtSteps.text = '(${steps} steps left)';
    _txtSteps.color = FlxColor.WHITE;
    if(steps <= 10) {
      // 残り10歩以下で点滅
      if(_tAnim%48 < 24) {
        _txtSteps.color = FlxColor.YELLOW;
      }
    }

    // HP更新
    _txtHp.text = '${player.hp}/${player.hpmax}';
    _txtHpEnemy.text = '${enemy.hp}';
    {
      // 敵の攻撃力と命中率
      var hit = EnemyDB.getHit(enemy.id);
      var str = '${enemy.str} Damage\n(${hit}%)';
      _txtAtkEnemy.text = str;
    }

    // HPゲージ更新
    _hpbarPlayer.setPercent(100 * player.hpratio);
    {
      var v = 100 * enemy.hpratio;
      if(v < 0) { v = 0; }
      _hpbarEnemy.setPercent(v);
    }

    _txtHp.color = _getHpTextColor(player);
    _txtHpEnemy.color = _getHpTextColor(enemy);

    // 食糧更新
    _txtFood.text = '${player.food}';
    _txtFood.color = _getFoodTextColor(player);

    // 所持金更新
    _txtMoney.text = '${Global.money}';

    // アイテム所持数
    _txtItem.text = 'Item (${ItemList.getLength()}/${ItemList.MAX})';

    // ステータス更新
    _txtStr.visible = false;
    _txtStr.text = 'STR: ${player.str}';
    _txtDex.text = 'DEX: ${player.dex}';
    _txtAgi.text = 'AGI: ${player.agi}';
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
   * 指定のボタンのアイコンを設定
   **/
  function _setButtonIcon(key:String, name:String, icon:String):Void {
    var group = _ui.getGroup(key);
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(widget.name != name) {
        return;
      }
      if(Std.is(widget, FlxUIButton)) {
        var btn:FlxUIButton = cast widget;
        btn.removeIcon();
        if(icon != "") {
          var spr = new FlxSprite(0, 0, icon);
          btn.addIcon(spr, -8, -6, false);
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
    var idx:Int = 0;
    group.visible = b;
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(Std.is(widget, FlxUIButton)) {
        // ボタンのみ
        var btn:FlxUIButton = cast widget;
        // ロックされていたら解除
        btn.skipButtonUpdate = false;
        btn.color = FlxColor.WHITE;
        btn.label.color = FlxColor.WHITE;
        var px = btn.x;
        if(b) {
          // スライドイン表示
          btn.x = -btn.width*2;
          FlxTween.tween(btn, {x:px}, 0.5, {ease:FlxEase.expoOut, startDelay:idx*0.05});
        }
        idx++;
      }
    });

    if(key == "enemyhud") {
      _hpbarEnemy.visible = b;
    }
  }

  /**
   * スプライト画像の設定
   **/
  function _setSpriteItem(key:String, name:String, path:String):Void {
    var group = _ui.getGroup(key);
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(widget.name == name) {
        if(Std.is(widget, FlxUISprite)) {
          var spr:FlxUISprite = cast widget;
          spr.loadGraphic(path);
        }
      }
    });
  }

  /**
   * テキストの設定
   **/
  function _setTextItem(key:String, name:String, msg:String):Void {
    var group = _ui.getGroup(key);
    group.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      if(widget.name == name) {
        if(Std.is(widget, FlxUIText)) {
          var txt:FlxUIText = cast widget;
          txt.text = msg;
        }
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
   * 食糧のテキストの中心座標を取得する
   **/
  function _getFoodPosition():FlxPoint {
    var px = _txtFood.x;
    var py = _txtFood.y - 8;
    var pt = FlxPoint.get(px, py);
    return pt;
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
  function _setButtonOverlapCB(func:String->Void):Void {
    _buttonOverlapCB = func;
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
        case FlxUITypedButton.OVER_EVENT:
          // ボタンの上にマウスがある
          // ボタンパラメータを判定
          if(fuib.params != null) {
            var key = fuib.params[0];
            if(_buttonOverlapCB != null) {
              _buttonOverlapCB(key);
            }
          }
      }
    }
  }
}
