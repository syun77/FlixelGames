package jp_2dgames.game.state;
import flixel.addons.ui.FlxUISubState;

/**
 * ショップSubState
 **/
class ShopSubState extends FlxUISubState {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 生成
   **/
  public override function create():Void {
    // TODO:
    _xml_id = "inventory";
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
