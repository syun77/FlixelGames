package jp_2dgames.game.gui;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ゲームUI
 **/
class GameUI extends FlxSpriteGroup {

  // 座標
  static inline var BASE_X = 0;
  static inline var BASE_Y = 0;
  // テキスト開始座標
  static inline var TEXT_X = 8;
  static inline var TEXT_Y = 8;
  static inline var TEXT_DY = 16;

  var _txtLimit:FlxText;
  var _txtScore:FlxText;
  var _txtSpeed:FlxText;

  var _funcSpeed:Void->Float;

  /**
   * コンストラクタ
   **/
  public function new(funcSpeed:Void->Float) {

    _funcSpeed = funcSpeed;

    super(BASE_X, BASE_Y);

    var txtList = new List<FlxText>();

    // スコアテキスト
    var px = TEXT_X;
    var py = TEXT_Y;
    _txtScore = new FlxText(px, py);
    txtList.add(_txtScore);
    py += TEXT_DY;

    // 速度
    _txtSpeed = new FlxText(px, py);
    txtList.add(_txtSpeed);
    py += TEXT_DY;

    // 残り時間
    _txtLimit = new FlxText(px, py);
    txtList.add(_txtLimit);

    for(txt in txtList) {
      this.add(txt);
      txt.setBorderStyle(FlxText.BORDER_OUTLINE);
    }

    // スクロール無効
    scrollFactor.set();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // 速度更新
    var score = Global.getScore();
    _txtScore.text = 'Score: ${score}';

    // 速度更新
    _txtSpeed.text = '${Std.int(_funcSpeed()/2)}km/h';

    // 残り時間更新
    _txtLimit.text = 'Remain: ${Std.int(LimitMgr.get())}';
    if(LimitMgr.isDanger()) {
      _txtLimit.color = FlxColor.RED;
    }
  }
}
