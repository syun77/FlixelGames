package jp_2dgames.game.gui;
import jp_2dgames.lib.MyColor;
import jp_2dgames.game.token.Enemy;
import jp_2dgames.lib.StatusBar;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flash.display.SpreadMethod;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.FlxG;
import jp_2dgames.game.global.Global;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  var _txtScore:FlxText;
  var _txtHp:FlxText;
  var _hpBar:StatusBar;
  var _txtHpEnemy:FlxText;
  var _hpBarEnemy:StatusBar;
  var _enemy:Enemy;
  var _txtturn:FlxText;

  var _barPower:StatusBar;
  var _barDefense:StatusBar;
  var _barSpeed:StatusBar;

  /**
   * コンストラクタ
   **/
  public function new(enemy:Enemy) {
    super(FlxG.width-64, 0);
    _enemy = enemy;

    var px:Float = 4;
    var py:Float = 4;

    // スコア
    _txtScore = new FlxText(px-(FlxG.width-64), py, 0, "", 8);
    this.add(_txtScore);

    // HPゲージ
    py += 34;
    _hpBar = new StatusBar(px-4, py, 24, 2);
    this.add(_hpBar);

    // HP
    py += 4;
    _txtHp = new FlxText(px-4, py, 0, "", 8);
    this.add(_txtHp);

    // 敵
    {
      var px2:Float = 36;
      var py2:Float = 4;
      // HPゲージ
      py2 += 34;
      _hpBarEnemy = new StatusBar(px2-4, py2, 24, 2);
      this.add(_hpBarEnemy);

      // HP
      py2 += 4;
      _txtHpEnemy = new FlxText(px2-4, py2, 0, "", 8);
      this.add(_txtHpEnemy);

      // ターン数
      _txtturn = new FlxText(px2-28, py2+10);
      this.add(_txtturn);
    }

    // 各種ゲージ
    px += 2;
    py += 32;
    {
      var spr = new FlxSprite(px-8, py);
      spr.loadGraphic(AssetPaths.IMAGE_ICON, true);
      spr.animation.add("play", [0], 1);
      spr.animation.play("play");
      this.add(spr);
    }
    _barPower = new StatusBar(px+2, py, 48, 2);
    _barPower.createFilledBar(0xff000051, MyColor.AQUAMARINE);
    this.add(_barPower);
    py += 8;
    {
      var spr = new FlxSprite(px-8, py);
      spr.loadGraphic(AssetPaths.IMAGE_ICON, true);
      spr.animation.add("play", [1], 1);
      spr.animation.play("play");
      this.add(spr);
    }
    _barDefense = new StatusBar(px+2, py, 48, 2);
    _barDefense.createFilledBar(0xff000051, MyColor.AZURE);
    this.add(_barDefense);
    py += 8;
    {
      var spr = new FlxSprite(px-8, py);
      spr.loadGraphic(AssetPaths.IMAGE_ICON, true);
      spr.animation.add("play", [2], 1);
      spr.animation.play("play");
      this.add(spr);
    }
    _barSpeed = new StatusBar(px+2, py, 48, 2);
    _barSpeed.createFilledBar(0xff005100, MyColor.LIME);
    this.add(_barSpeed);
    py += 8;

    scrollFactor.set();
  }

  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    // スコア
    _txtScore.text = 'SCORE: ${Global.score}';

    // HP
    _txtHp.text = '${Global.life}';
    _hpBar.setPercent(100 * Global.life / Global.MAX_LIFE);

    // HP(敵)
    _txtHpEnemy.text = '${_enemy.hp}';
    _hpBarEnemy.setPercent(100 * _enemy.hpratio);
    _txtturn.text = 'TURN: ${_enemy.turn}';

    // 各種ゲージ
    _barPower.setPercent(Gauge.power);
    _barDefense.setPercent(Gauge.defense);
    _barSpeed.setPercent(Gauge.speed);
  }
}
