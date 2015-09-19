package jp_2dgames.game;

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