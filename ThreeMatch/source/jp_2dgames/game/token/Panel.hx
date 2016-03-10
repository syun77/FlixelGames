package jp_2dgames.game.token;

import flixel.FlxG;
import jp_2dgames.game.token.Panel.PanelType;
import flixel.FlxState;

enum PanelType {
  Sword;  // 剣
  Shield; // 盾
  Shoes;  // 靴
  Life;   // ライフ
  Skull;  // ドクロ
}

/**
 * パネル
 **/
class Panel extends Token {

  public static var parent:TokenMgr<Panel>;
  public static function createParent(state:FlxState):Void {
    parent = new TokenMgr<Panel>(Field.WIDTH*Field.HEIGHT, Panel);
    var i:Int = 0;
    for(panel in parent.members) {
      panel.ID = i;
      i++;
    }
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:PanelType, i:Int, j:Int):Panel {
    var panel:Panel = parent.recycle();
    panel.init(type, i, j);
    return panel;
  }
  public static function killAll():Void {
    parent.forEachAlive(function(panel:Panel) {
      panel.kill();
    });
  }
  // 指定の座標にあるパネルを取得する
  public static function getFromIdx(i:Int, j:Int):Panel {
    var ret:Panel = null;
    parent.forEachAlive(function(panel:Panel) {
      if(panel.xgrid == i && panel.ygrid == j) {
        ret = panel;
      }
    });
    return ret;
  }
  public static function randomType():PanelType {
    var tbl = [
      PanelType.Sword,
      PanelType.Shield,
      PanelType.Shoes,
      PanelType.Life,
      PanelType.Skull,
    ];

    FlxG.random.shuffleArray(tbl, 3);
    return tbl[0];
  }

  // -----------------------------------------------------------------------
  // ■フィールド
  var _xgrid:Int;
  public var xgrid(get, never):Int;
  var _ygrid:Int;
  public var ygrid(get, never):Int;
  var _type:PanelType;
  public var type(get, never):PanelType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PANEL, true);
    _registerAnim();
    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:PanelType, i:Int, j:Int):Void {
    _type = type;
    _xgrid = i;
    _ygrid = j;
    x = Field.toWorldX(i);
    y = Field.toWorldY(j);

    animation.play('${_type}');
  }

  /**
   * アニメ登録
   **/
  function _registerAnim():Void {
    animation.add('${PanelType.Sword}',  [0], 1);
    animation.add('${PanelType.Shield}', [1], 1);
    animation.add('${PanelType.Shoes}',  [2], 1);
    animation.add('${PanelType.Life}',   [3], 1);
    animation.add('${PanelType.Skull}',  [4], 1);
  }

  // -----------------------------------------------------------------------
  // ■アクセサ
  function get_type() {
    return _type;
  }
  function get_xgrid() {
    return _xgrid;
  }
  function get_ygrid() {
    return _ygrid;
  }

}
