package jp_2dgames.game.token;
import flixel.FlxObject;
import jp_2dgames.game.token.Block.BlockType;
import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

/**
 * ブロックの種類
 **/
enum BlockType {
  Lock;   // カギ穴ブロック
  Red;    // 赤ブロック
  Green;  // 緑ブロック
  Blue;   // 青ブロック
  Yellow; // 黄色ブロック
}

/**
 * 動かないブロック
 **/
class Block extends Token {

  public static var parent:FlxTypedGroup<Block> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Block>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(type:BlockType, X:Float, Y:Float):Block {
    var block:Block = parent.recycle(Block);
    block.init(type, X, Y);
    return block;
  }
  public static function changeAll(type:BlockType, b:Bool):Void {
    parent.forEachAlive(function(block:Block) {
      block._change(type, b);
    });
  }

  // ===================================================================
  // ■フィールド
  var _type:BlockType;
  var _enable:Bool;

  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK, true);
    // アニメーション登録
    _registerAnim();
    immovable = true;
  }

  /**
   * 初期化
   **/
  public function init(type:BlockType, X:Float, Y:Float):Void {
    _type = type;
    x = X;
    y = Y;
    _enable = true;

    // アニメ再生
    _playAnim();
  }

  /**
   * カギを使う
   * @return カギを使うことができたらtrue
   **/
  public function useKey():Bool {

    if(_type != BlockType.Lock) {
      // 壊せない
      return false;
    }

    // カギを使った
    Particle.start(PType.Circle, xcenter, ycenter, FlxColor.BROWN);

    // カギを減らす
    Global.subKey();

    // 少し揺らす
    FlxG.camera.shake(0.01, 0.2);

    Snd.playSe("damage");
    // 消滅
    kill();

    return true;
  }

  function _change(type:BlockType, b:Bool):Void {
    if(type == _type) {
      _enable = b;
      _playAnim();
      solid = b;
    }
  }

  function _registerAnim():Void {
    _enable = true;
    animation.add('${BlockType.Lock}${_enable}',   [0, 1], 4);
    animation.add('${BlockType.Red}${_enable}',    [2], 4);
    animation.add('${BlockType.Green}${_enable}',  [3], 4);
    animation.add('${BlockType.Blue}${_enable}',   [4], 4);
    animation.add('${BlockType.Yellow}${_enable}', [5], 4);
    _enable = false;
    animation.add('${BlockType.Lock}${_enable}',   [0, 1], 4);
    animation.add('${BlockType.Red}${_enable}',    [6], 4);
    animation.add('${BlockType.Green}${_enable}',  [7], 4);
    animation.add('${BlockType.Blue}${_enable}',   [8], 4);
    animation.add('${BlockType.Yellow}${_enable}', [9], 4);
  }

  function _playAnim():Void {
    animation.play('${_type}${_enable}');
  }
}
