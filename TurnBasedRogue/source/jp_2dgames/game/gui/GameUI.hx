package jp_2dgames.game.gui;

import jp_2dgames.game.state.PlayState;
import flixel.util.FlxColor;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  static inline var FONT_SIZE:Int = 16;

  var _txtLevel:FlxText;
  var _txtHp:FlxText;
  var _txtturn:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(FlxG.width-160, 0);

    var dy:Float = 20;

    var px:Float = 4;
    var py:Float = 4;

    // レベル
    _txtLevel = new FlxText(px, py-2, 0, "", FONT_SIZE);
    this.add(_txtLevel);

    // HP
    py += dy;
    _txtHp = new FlxText(px, py, 0, "", FONT_SIZE);
    this.add(_txtHp);

    // 残りターン数
    py += dy;
    _txtturn = new FlxText(px, py, 0, "", FONT_SIZE);
    this.add(_txtturn);

    scrollFactor.set();
  }

  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    // レベル
    _txtLevel.text = 'LEVEL: ${Global.level}';

    // HP
    {
      var player = cast(FlxG.state, PlayState).player;
      _txtHp.text = 'HP: ${player.params.hp}';
    }

    var turn = Global.turn;
    _txtturn.text = 'TURN: ${turn}';
    _txtturn.color = FlxColor.WHITE;
    if(turn <= 5) {
      _txtturn.color = FlxColor.RED;
    }
    else if(turn <= 10) {
      _txtturn.color = FlxColor.YELLOW;
    }
  }
}
