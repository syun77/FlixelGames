package jp_2dgames.game.state;

import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIButton;
import jp_2dgames.game.dat.UpgradeDB;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.actor.ActorMgr;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUISubState;

/**
 * メインゲーム強化メニュー
 **/
class UpgradeSubState extends FlxUISubState {

  // -------------------------------------------
  // ■フィールド
  var _btnHpMax:FlxUIButton;
  var _btnDex:FlxUIButton;
  var _btnAgi:FlxUIButton;

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "upgrade";
    super.create();

    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "btnhp":
          _btnHpMax = cast widget;
        case "btndex":
          _btnDex = cast widget;
        case "btnagi":
          _btnAgi = cast widget;
      }
    });

    // 項目更新
    _updateItems();
  }

  /**
   * 破棄
   **/
  public override function destroy():Void {
    super.destroy();
  }

  /**
   * 項目の更新
   **/
  function _updateItems():Void {
    var player = ActorMgr.getPlayer();
    // HP
    {
      var cost = UpgradeDB.getHpMax(player.hpmax - 10);
      _setBtnInfo(_btnHpMax, '最大HP', cost, player.food);
    }
    // DEX
    {
      var cost = UpgradeDB.getDex(player.dex);
      _setBtnInfo(_btnDex, 'DEX', cost, player.food);
    }
    // AGI
    {
      var cost = UpgradeDB.getAgi(player.agi);
      _setBtnInfo(_btnAgi, 'AGI', cost, player.food);
    }
  }

  /**
   * ボタン情報を設定する
   **/
  function _setBtnInfo(btn:FlxUIButton, label:String, cost:Int, food:Int):Void {

    var bBuy = false;
    var txt = '${label} +1 (${cost})';
    if(food >= cost) {
      // 購入可能
      bBuy = true;
    }
    if(cost < 1) {
      // 最大レベルなので買えない
      txt = '${label} +1 (-)';
      bBuy = false;
    }
    btn.label.text = txt;

    if(bBuy) {
      // 購入可能
      btn.skipButtonUpdate = false;
      btn.color = FlxColor.WHITE;
      btn.label.color = FlxColor.WHITE;
    }
    else {
      // 購入できない
      btn.skipButtonUpdate = true;
      btn.color = FlxColor.GRAY;
      btn.label.color = FlxColor.GRAY;
    }
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    var widget:IFlxUIWidget = cast sender;
    if(widget != null && Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          // ボタンパラメータを判定
          if(fuib.params != null) {
            var key = fuib.params[0];
            switch(key) {
              case "btnhp":
                _updateHpMax();
              case "btndex":
                _upgradeDex();
              case "btnagi":
                _upgradeAgi();
              case "close":
                // おしまい
                close();
            }
          }
      }
    }
  }

  /**
   * 最大HPを上昇させる
   **/
  function _updateHpMax():Void {
    var player = ActorMgr.getPlayer();
    // 食糧を減らす
    var cost = UpgradeDB.getHpMax(player.hpmax - 10);
    player.subFood(cost);
    player.addHpMax(1);
    // UIの表示項目を更新
    BattleUI.forceUpdate(0);
    // 項目更新
    _updateItems();
  }

  /**
   * DEXを上昇させる
   **/
  function _upgradeDex():Void {
    var player = ActorMgr.getPlayer();
    // 食糧を減らす
    var cost = UpgradeDB.getHpMax(player.dex);
    player.subFood(cost);
    player.addDex(1);
    // UIの表示項目を更新
    BattleUI.forceUpdate(0);
    // 項目更新
    _updateItems();
  }

  /**
   * AGIを上昇させる
   **/
  function _upgradeAgi():Void {
    var player = ActorMgr.getPlayer();
    // 食糧を減らす
    var cost = UpgradeDB.getHpMax(player.agi);
    player.subFood(cost);
    player.addAgi(1);
    // UIの表示項目を更新
    BattleUI.forceUpdate(0);
    // 項目更新
    _updateItems();
  }
}
