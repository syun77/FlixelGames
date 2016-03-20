package jp_2dgames.game.item;

import flixel.FlxSprite;
import jp_2dgames.game.item.ItemType;
import jp_2dgames.game.gui.MyButton;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * インベントリUI
 **/
class InventoryUI extends FlxSpriteGroup {

  static inline var DY:Int = 36;

  // ----------------------------------------------
  var _btnList:Array<MyButton>;
  var _iconList:Array<FlxSprite>;

  /**
   * コンストラクタ
   **/
  public function new() {

    var xbase = FlxG.width-160;
    var ybase = 80;
    super(xbase, ybase);

    _btnList = new Array<MyButton>();
    _iconList = new Array<FlxSprite>();
    for(i in 0...Inventory.MAX) {
      var py = i * DY;
      // アイコン
      var icon = new FlxSprite(4, py);
      icon.loadGraphic(AssetPaths.IMAGE_ITEM, true);
      for(i in 0...8) {
        icon.animation.add('${i}', [i], 1);
      }
      _iconList.push(icon);
      this.add(icon);
      icon.visible = false;
      // ボタン
      var btn = new MyButton(4+32, py, "", function() {
        _useItem(i);
      });
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
      var btn:MyButton = _btnList[idx];
      var icon:FlxSprite = _iconList[idx];
      if(type == ItemType.INVALID) {
        // 空
        btn.visible = false;
        icon.visible = false;
      }
      else {
        // 所持している
        btn.visible = true;
        btn.ID   = idx;
        btn.text = ItemType.toName(type);
        icon.visible = true;
        icon.animation.play('${Inventory.get(idx)}');
      }
    });
  }

  function _useItem(idx:Int):Void {
    var btn:MyButton = _btnList[idx];
    var icon:FlxSprite = _iconList[idx];
    if(btn.visible == false) {
      // 無効なボタン
      return;
    }
    var index = btn.ID;
    // アイテムを使う
    var type = ItemType.get(Inventory.get(index));
    if(SeqMgr.useItem(type)) {
      // アイテムを使用できた
      Inventory.use(index);
      btn.visible = false;
      icon.visible = false;
    }
  }

}
