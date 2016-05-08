package jp_2dgames.lib;

import jp_2dgames.lib.DirUtil.Dir;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;

/**
 * トランジション
 **/
class MyTransition {

  static inline var DIAMOND_WIDTH:Int = 32;
  static inline var DIAMOND_HEIGHT:Int = 32;

  /**
   * 生成
   **/
  public static function create():Void {
    FlxTransitionableState.defaultTransIn = new TransitionData();
    FlxTransitionableState.defaultTransOut = new TransitionData();

    var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
    diamond.persist = true;
    diamond.destroyOnNoUse = false;

    FlxTransitionableState.defaultTransIn.tileData = { asset:diamond, width:DIAMOND_WIDTH, height:DIAMOND_HEIGHT };
    FlxTransitionableState.defaultTransOut.tileData = { asset:diamond, width:DIAMOND_WIDTH, height:DIAMOND_HEIGHT };

    setIn();
    setOut();
  }

  /**
   * フェードアウトパラメータの設定
   **/
  public static function setIn():Void {
    var inData:TransitionData = FlxTransitionableState.defaultTransIn;
    _set(inData);
  }

  /**
   * フェードインパラメータの設定
   **/
  public static function setOut():Void {
    var outData:TransitionData = FlxTransitionableState.defaultTransOut;
    _set(outData);
  }

  static function _set(data:TransitionData):Void {
    data.type = TransitionType.TILES;
    data.color = FlxColor.BLACK;
    data.duration = 0.5;
    data.direction = DirUtil.getVector(Dir.Right);
    data.tileData.asset = _getDefaultAsset("diamond");
  }

  static function _getDefaultAsset(str):FlxGraphic {
    var graphicClass:Class<Dynamic> = switch (str)
    {
      case "circle": GraphicTransTileCircle;
      case "square": GraphicTransTileSquare;
      case "diamond", _: GraphicTransTileDiamond;
    }

    var graphic:FlxGraphic = FlxGraphic.fromClass(cast graphicClass);
    graphic.persist = true;
    graphic.destroyOnNoUse = false;
    return graphic;
  }
}
