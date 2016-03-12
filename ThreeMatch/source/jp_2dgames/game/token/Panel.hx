package jp_2dgames.game.token;

import jp_2dgames.game.global.Global;
import flixel.util.FlxArrayUtil;
import flixel.tweens.FlxEase;
import lime.tools.helpers.NekoHelper;
import flixel.tweens.FlxTween;
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
  public static function add(type:PanelType, i:Int, j:Int, yofs:Int):Panel {
    var panel:Panel = parent.getFirstAvailable();
    panel.revive();
    panel.init(type, i, j, yofs);
    return panel;
  }
  public static function killAll():Void {
    parent.forEachAlive(function(panel:Panel) {
      panel.kill();
    });
  }
  // 移動中かどうか
  public static function isMoving():Bool {
    var ret = false;
    parent.forEachAlive(function(panel:Panel) {
      if(panel._bMoving) {
        ret = true;
      }
    });
    return ret;
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
    var max = 99 + Std.int(Global.level);
    if(max > 120) {
      max = 120;
    }
    var rnd = FlxG.random.int(0, max);
    if(rnd <= 99) {
      var tbl = [
        PanelType.Sword,
        PanelType.Shield,
        PanelType.Shoes,
        PanelType.Life
      ];
      var idx = FlxG.random.int(0, tbl.length-1);
      return tbl[idx];
    }
    else {
      return PanelType.Skull;
    }
  }

  // -----------------------------------------------------------------------
  // ■フィールド
  var _xgrid:Int;
  public var xgrid(get, never):Int;
  var _ygrid:Int;
  public var ygrid(get, never):Int;
  var _type:PanelType;
  public var type(get, never):PanelType;
  var _bMoving:Bool;

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
  public function init(type:PanelType, i:Int, j:Int, yofs:Int):Void {
    _type = type;
    _xgrid = i;
    _ygrid = j-yofs;
    _bMoving = false;
    x = Field.toWorldX(i);
    y = Field.toWorldY(j-yofs);

    animation.play('${_type}');

    move(j);
  }

  public function move(ytarget:Int):Void {
    var d = ytarget - _ygrid;
    _ygrid = ytarget;
    var py = Field.toWorldY(ytarget);
    var func = function(t:Float) {return t;}
    FlxTween.tween(this, {y:py}, 0.1*d, {ease:FlxEase.sineIn, onComplete:function(tween:FlxTween) {
      // 移動完了
      _bMoving = false;
    }});
    // 移動中
    _bMoving = true;
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
