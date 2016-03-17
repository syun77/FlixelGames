package jp_2dgames.game.item;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.group.FlxSpriteGroup;

/**
 * インベントリUI
 **/
class InventoryUI extends FlxSpriteGroup {

  static inline var DY:Int = 36;

  // ----------------------------------------------
  var _btnList:Array<FlxButton>;

  /**
   * コンストラクタ
   **/
  public function new() {

    var xbase = FlxG.width-160;
    var ybase = 80;
    super(xbase, ybase);

    _btnList = new Array<FlxButton>();
    for(i in 0...Inventory.MAX) {
      var py = i * DY;
      var btn = new FlxButton(4, py);
      _btnList.push(btn);
      this.add(btn);
      btn.visible = false;
    }
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    Inventory.forEach(function(idx:Int, type:Int) {
      var btn:FlxButton = _btnList[idx];
      if(type == ItemType.INVALID) {
        // 空
        btn.visible = false;
      }
      else {
        // 所持している
        btn.visible = true;
        btn.ID   = idx;
        btn.text = ItemType.toName(type);
      }
    });
  }

}
