package jp_2dgames.game.token;

import flixel.group.FlxTypedGroup;

/**
 * Token管理
 **/
class TokenMgr<T:Token> extends FlxTypedGroup<T> {
  public function new(MaxSize:Int, ObjectClass:Class<T>) {
    super(MaxSize);
    for(i in 0...maxSize) {
      this.add(Type.createInstance(ObjectClass, []));
    }
  }
}
