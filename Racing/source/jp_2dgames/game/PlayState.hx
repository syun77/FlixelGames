package jp_2dgames.game;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム
 **/
class PlayState extends FlxState {

  var _player:Player;

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

    var bgHandle = new FlxSprite(0, FlxG.height/2+32);
    bgHandle.makeGraphic(FlxG.width, Std.int(FlxG.height/2), FlxColor.BLACK);
    bgHandle.scrollFactor.set(0, 0);
    this.add(bgHandle);
    // ハンドルUI
    var handle = new HandleUI(0, FlxG.height/2+32);
    this.add(handle);

    // プレイヤーをカメラが追いかける
    FlxG.camera.follow(_player);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }
}