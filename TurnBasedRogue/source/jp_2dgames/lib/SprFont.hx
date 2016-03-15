package jp_2dgames.lib;

import flash.geom.Point;
import flixel.FlxG;
import flixel.util.FlxColor;
import flash.geom.Rectangle;
import flixel.FlxSprite;

/**
 * スプライトフォント
 **/
class SprFont {

  // 一文字の幅
  public static inline var FONT_WIDTH:Int = 16;

  // スプライトフォントのパス
  static var _path:String = "assets/font/font16x16.png";

  // 文字の並び
  static var _conv:String = "0123456789"
    + "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    + ".()[]#$%&'" + '"'
    + "!?^+-*/=;:_<>" + "|@`";


  /**
   * フォントのパスを設定する
   **/
  public static function setBmpPath(path:String):Void {
    _path = path;
  }

  /**
   * 指定の文字のスプライトフォントにおけるインデックスを取得する
   **/
  private static function _charToIdx(char:String):Int {
    return _conv.indexOf(char);
  }

  /**
   * BitmapDataに文字をレンダリングする
   * @param spr 描画するスプライト
   * @param str 描画する文字
   * @return レンダリングの幅
   **/
  public static function render(spr:FlxSprite, str:String):Int {

    // 描画をクリアする
    spr.pixels.fillRect(new Rectangle(0, 0, spr.pixels.width, FONT_WIDTH), FlxColor.TRANSPARENT);

    // フォント画像読み込み
    var bmp = FlxG.bitmap.add(_path);
    var pt = new Point();
    var rect = new Rectangle(0, 0, FONT_WIDTH, FONT_WIDTH);
    // 数字の桁数を求める
    var digit = str.length;
    for(i in 0...digit) {
      // フォントをレンダリングする
      pt.x = i * FONT_WIDTH;
      var idx = _charToIdx(str.charAt(i));
      if(idx == -1) {
        continue;
      }
      rect.left = idx * FONT_WIDTH;
      rect.right = rect.left + FONT_WIDTH;
      spr.pixels.copyPixels(bmp.bitmap, rect, pt);
    }

    // 描画を反映
    spr.dirty = true;
    spr.updateFramePixels();

    // レンダリングの幅を返す
    return (FONT_WIDTH * digit);
  }
}
