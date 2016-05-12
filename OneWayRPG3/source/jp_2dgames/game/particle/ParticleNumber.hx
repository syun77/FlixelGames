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
class ParticleNumber extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = SprFont.FONT_WIDTH;

  // 表示時間
  static inline var TIMER_EXIST:Int = 60;

  // ■速度関連
  // 開始速度
  static inline var SPEED_Y_INIT:Float = -5.0;//-20.0;
  // 重力加速度
  static inline var GRAVITY:Float = 15.0;
  // 床との反発係数
  static inline var FRICTION:Float = 0.5;

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleNumber> = null;
  /**
   * 生成
   **/
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleNumber>(16);
    for(i in 0...parent.maxSize) {
      parent.add(new ParticleNumber());
    }
    state.add(parent);
  }
  /**
   * 破棄
   **/
  public static function destroyParent():Void {
    parent = null;
  }

  public static function start(X:Float, Y:Float, val:Int, color:Int=FlxColor.WHITE):ParticleNumber {
    var p:ParticleNumber = parent.recycle();
    p.init(X, Y, val);
    p.color = color;
    return p;
  }

  /**
   * 外部から更新
   **/
  public static function forceUpdate(elapsed:Float):Void {
    parent.update(elapsed);
  }

  // ----------------------------------------------------------
  // ■フィールド
  // 開始座標
  var _ystart:Float;
  var _state:State;
  var _timer:Int;

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
    if(val >= 0) {
      // 数値フォントを描画する
      w = SprFont.render(this, '${val}');
    }
    else {
      // 攻撃が外れた
      w = SprFont.render(this, 'MISS!');
    }
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
    _timer = TIMER_EXIST;
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
