package jp_2dgames.game.particle;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import jp_2dgames.lib.SprFont;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 状態
 **/
private enum State {
  Main;  // メイン
  Fade;  // フェードで消える
}

/**
 * ダメージエフェクト
 **/
class ParticleScore extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = SprFont.FONT_WIDTH;

  // ■速度関連
  // 開始速度
  static inline var SPEED_Y_INIT:Float = -5.0;//-20.0;
  // 重力加速度
  static inline var GRAVITY:Float = 15.0;
  // 床との反発係数
  static inline var FRICTION:Float = 0.5;

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleScore> = null;
  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleScore>(16);
    for(i in 0...parent.maxSize) {
      parent.add(new ParticleScore());
    }
    state.add(parent);
  }
  /**
   * 破棄
   **/
  public static function destroyParent():Void {
    parent = null;
  }

  public static function start(X:Float, Y:Float, val:Int):ParticleScore {
    var p:ParticleScore = parent.recycle();
    p.init(X, Y, val);
    return p;
  }

  // 開始座標
  private var _ystart:Float;
  private var _state:State;
  private var _timer:Int;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    makeGraphic(FONT_SIZE * 8, FONT_SIZE, FlxColor.TRANSPARENT, true);

    // 非表示にしておく
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, val:Int) {

    // カメラ位置をオフセット
    X += -FlxG.camera.scroll.x;
    Y += -FlxG.camera.scroll.y;

    x = X;
    y = Y;
    _ystart = Y;

    var w = 0;
    // 数値フォントを描画する
    var w = SprFont.render(this, '${val}');
    // 移動開始
    velocity.y = SPEED_Y_INIT;

    // フォントを中央揃えする
    x = X - (w / 2);

    visible = true;
    alpha = 1;

    // スクロール無効
    scrollFactor.set();

    // メイン状態へ
    _state = State.Main;
    _timer = 30;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    switch(_state) {
      case State.Main:
        _timer--;
        if(_timer == 0) {
          // フェードで消える
          _state = State.Fade;
        }

      case State.Fade:
        // フェードで消える
        alpha -= 1.0 / 30;
        if(alpha < 0) {
          kill();
        }
    }

  }
}
