package jp_2dgames.game;

import flixel.text.FlxText;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player = null;
  var _timer:Int = 0;
  var _txt:FlxText;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new Bg());

    // プレイヤー
    _player = new Player(FlxG.width/2, FlxG.height/2);
    this.add(_player);

    // 敵
    Enemy.createParent(this);

    var bgHandle = new FlxSprite(0, FlxG.height/2+32);
    bgHandle.makeGraphic(FlxG.width, Std.int(FlxG.height/2), FlxColor.BLACK);
    bgHandle.scrollFactor.set(0, 0);
    this.add(bgHandle);

    // ハンドルUI
    var handle = new HandleUI(0, FlxG.height/2+32, _player);
    this.add(handle);

    _txt = new FlxText(0, 0);
    _txt.scrollFactor.set();
    this.add(_txt);

    // プレイヤーをカメラが追いかける
    FlxG.camera.follow(_player);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    _player = null;
    Enemy.destroyParent(this);

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _txt.text = 'Enemy: ${Enemy.count()}';

    _timer++;
    if(_timer%120 == 0) {
      var px = Wall.randomX();
      var py = FlxG.camera.scroll.y - 32;
      var spd = FlxRandom.floatRanged(5, 20);
      Enemy.add(px, py, spd);
    }
  }
}