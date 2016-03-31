package jp_2dgames.game.token;

import jp_2dgames.lib.AdvScript;
import flixel.text.FlxText;
import jp_2dgames.lib.StatusBar;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.AttributeUtil.Attribute;
import flixel.util.FlxColor;

/**
 * ボス
 **/
class Boss extends Enemy {

  // ------------------------------------------
  // ■フィールド
  var _hpmax:Int;
  var _txtHp:FlxText;
  var _hpbar:StatusBar;
  public var hpbar(get, never):StatusBar;
  public var txtHp(get, never):FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _txtHp = new FlxText();
    _hpbar = new StatusBar(0, 0, 32, 4);
  }

  /**
   * 初期化
   **/
  public function init2(eid:Int, X:Float, Y:Float):Void {
    _eid = eid;
    x = X;
    y = Y;
    _size  = EnemyInfo.getRadius(_eid);
    _hp    = EnemyInfo.getHp(_eid);
    _hpmax = _hp;
    _tDestroy = EnemyInfo.getDestroy(_eid);
    color  = FlxColor.GREEN;
    makeGraphic(_size, _size);
    _timer = 0;

    // AI生成
    var script = AssetPaths.getAIScript(EnemyInfo.getAI(_eid));
    _ai = new EnemyAI(this, script);
  }

  /**
   * 消滅
   **/
  override public function vanish():Void {
    Global.addScore(EnemyInfo.getScore(_eid));
    selfDestruction();
  }

  /**
   * 自爆
   **/
  override public function selfDestruction():Void {
    Particle.start(PType.Ball, xcenter, ycenter, FlxColor.GREEN);
    Particle.start(PType.Ring, xcenter, ycenter, FlxColor.GREEN);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _updateStatus();

    /*
    if(_timer%60 == 0) {
      var id:Int = 11;
      Enemy.add(id, Attribute.Red, xcenter, ycenter, 135, 150);
      Enemy.add(id, Attribute.Red, xcenter, ycenter, 225, 150);
      _timer++;
    }
    */
  }

  /**
   * ステータス表示を更新
   **/
  function _updateStatus():Void {
    _hpbar.x = x;
    _hpbar.y = y+height+2;
    _hpbar.setPercent(100 * _hp / _hpmax);
    _txtHp.x = xcenter;
    _txtHp.y = ycenter;
    _txtHp.text = '${_hp}';
  }

  // -----------------------------------------------------
  // ■アクセサ
  function get_hpbar() {
    return _hpbar;
  }
  function get_txtHp() {
    return _txtHp;
  }
}
