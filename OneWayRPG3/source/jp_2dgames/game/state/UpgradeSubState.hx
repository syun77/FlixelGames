package jp_2dgames.game.state;

import jp_2dgames.game.dat.UpgradeDB;
import flixel.ui.FlxVirtualPad.FlxActionMode;
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

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "powerup";
    super.create();
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
    var cost = UpgradeDB.getHpMax(player.hpmax - 10);
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
    player.addHpMax(1);
    // UIの表示項目を更新
    BattleUI.forceUpdate(0);
  }

  /**
   * DEXを上昇させる
   **/
  function _upgradeDex():Void {
    var player = ActorMgr.getPlayer();
    player.addDex(1);
    // UIの表示項目を更新
    BattleUI.forceUpdate(0);
  }

  /**
   * AGIを上昇させる
   **/
  function _upgradeAgi():Void {
    var player = ActorMgr.getPlayer();
    player.addAgi(1);
    // UIの表示項目を更新
    BattleUI.forceUpdate(0);
  }
}
