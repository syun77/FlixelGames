package jp_2dgames.game.gui;
import flixel.addons.ui.FlxUIPopup;

/**
 * バトルリザルト
 **/
class BattleResultUI extends FlxUIPopup {

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "battle_result";
    super.create();
  }

  /**
   * 破棄
   **/
  public override function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {
    super.update(elapsed);
  }

}
