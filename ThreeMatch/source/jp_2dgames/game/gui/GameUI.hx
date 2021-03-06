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

  var _txtLevel:FlxText;
  var _txtHp:FlxText;
  var _hpBar:StatusBar;
  var _txtHpEnemy:FlxText;
  var _hpBarEnemy:StatusBar;
  var _enemy:Enemy;
  var _txtturn:FlxText;

  var _barPower:StatusBar;
  var _barDefense:StatusBar;
  var _barSpeed:StatusBar;
  var _txtPower:FlxText;
  var _txtDefense:FlxText;

  var _btnSword:FlxButton;
  var _btnShoes:FlxButton;

  /**
   * コンストラクタ
   **/
  public function new(enemy:Enemy, cbKillSkull:Int->Void, cbShoes:Int->Void) {
    super(FlxG.width-64, 0);
    _enemy = enemy;

    var px:Float = 4;
    var py:Float = 4;

    // レベル
    _txtLevel = new FlxText(px, py-2, 0, "", 8);
    this.add(_txtLevel);

    // HPゲージ
    py += 34;
    _hpBar = new StatusBar(px-4, py, 24, 2);
    this.add(_hpBar);

    // HP
    py += 2;
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
      py2 += 2;
      _txtHpEnemy = new FlxText(px2-4, py2, 0, "", 8);
      this.add(_txtHpEnemy);

      // ターン数
      _txtturn = new FlxText(px2-28, py2+12);
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
    _txtPower = new FlxText(px, py);
    this.add(_txtPower);

    py += 12;
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
    _txtDefense = new FlxText(px, py);
    this.add(_txtDefense);

    py += 12;
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
    py += 2;

    // 必殺技ボタン
    _btnSword = new FlxButton(px, py, "kill 0", function() {
      cbKillSkull(Calc.getSwordKill());
    });
    _btnSword.loadGraphic(AssetPaths.IMAGE_BUTTON, true, 48, 20);
    this.add(_btnSword);

    py += 24;

    _btnShoes = new FlxButton(px, py, "delay 0", function() {
     cbShoes(Calc.getShoes());
    });
    _btnShoes.loadGraphic(AssetPaths.IMAGE_BUTTON, true, 48, 20);
    this.add(_btnShoes);

    scrollFactor.set();
  }

  public override function update(elapsed:Float):Void {
    super.update(elapsed);

    // レベル
    _txtLevel.text = 'LEVEL: ${Global.level}';

    // HP
    _txtHp.text = '${Global.life}';
    _hpBar.setPercent(100 * Global.life / Global.MAX_LIFE);

    // HP(敵)
    _txtHpEnemy.text = '${_enemy.hp}';
    _hpBarEnemy.setPercent(100 * _enemy.hpratio);
    var turn = _enemy.turn;
    _txtturn.text = 'TURN: ${turn}';
    _txtturn.color = FlxColor.WHITE;
    if(turn <= 1) {
      _txtturn.color = FlxColor.RED;
    }
    if(turn == 2) {
      _txtturn.color = FlxColor.YELLOW;
    }

    // ビンチかどうか
    var bDanger = false;
    var damage = Calc.Damage(_enemy.getEnemyID());
    if(Global.life <= damage) {
      // ピンチ
      bDanger = true;
    }

    // 各種ゲージ
    _barPower.setPercent(Gauge.power);
    var pow = Calc.getPower();
    pow = Std.int(pow * 100) / 100;
    _txtPower.text = 'x${pow}';
    _barDefense.setPercent(Gauge.defense);
    var def = Std.int(Calc.getDefense() / 10) / 10;
    _txtDefense.text = 'x${def}(${damage})';
    _txtDefense.color = FlxColor.WHITE;
    if(bDanger) {
      _txtDefense.color = FlxColor.RED;
    }
    _barSpeed.setPercent(Gauge.speed);

    // ボタン
    _btnSword.text = 'kill ${Calc.getSwordKill()}';
    _btnShoes.text = 'delay ${Calc.getShoes()}';
  }
}
