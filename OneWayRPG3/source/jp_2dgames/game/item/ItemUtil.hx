package jp_2dgames.game.item;

import jp_2dgames.game.sequence.btl.BtlLogic;
import jp_2dgames.game.sequence.btl.BtlLogicFactory;
import jp_2dgames.game.SeqMgr;
import jp_2dgames.game.sequence.btl.BtlCalc;
import jp_2dgames.game.SeqMgr;
import jp_2dgames.game.dat.ResistData.ResistList;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.ItemDB;
import jp_2dgames.lib.TextUtil;
import flixel.FlxG;
import jp_2dgames.game.dat.MyDB;

/**
 * アイテムの分類
 **/
enum ItemCategory {
  Portion;
  Weapon;
}

/**
 * アイテム操作のユーティリティ
 **/
class ItemUtil {

  // 名前を取得
  public static function getName(item:ItemData):String {
    var name = getName2(item);
    return '${name} (${item.now}/${item.max})';
  }
  public static function getName2(item:ItemData):String {
    var name = ItemDB.getName(item.id);
    if(item.buff > 0) {
      // 強化ポイント表示
      name = '${name}+${item.buff}';
    }
    return name;
  }

  // 威力を取得
  public static function getPower(item:ItemData):Int {
    return ItemDB.getPower(item.id) + item.buff;
  }

  // 命中率を取得
  public static function getHit(item:ItemData):Int {
    return ItemDB.getHit(item.id);
  }

  // 属性を取得
  public static function getAttribute(item:ItemData):Attribute {
    return AttributeUtil.fromKind(ItemDB.getAttribute(item.id));
  }

  // 詳細情報の取得
  public static function getDetail(item:ItemData):String {
    return ItemDB.getDetail(item.id);
  }

  // 詳細情報の取得
  public static function getDetail2(owner:SeqMgr, item:ItemData, resists:ResistList):String {

    var player = owner.player;
    var enemy = owner.enemy;

    var ret = "";
    var str = player.str;
    var power = getPower(item) + str;
    var count = getCount(item);
    var attr  = getAttribute(item);
    var hitratio = BtlCalc.hit(getHit(item), player, enemy);
    var sum = calcDamage(owner, item, true, resists);
    if(getCategory(item) == ItemCategory.Weapon) {
      // 武器
      var power = TextUtil.fillSpace(power, 2); // flash対応
      if(item.now == 1) {
        // 最後の一撃
        ret += '攻: ${power} x 3 \n';
      }
      else {
        ret += '攻: ${power} \n';
      }
      if(count > 1) {
        var count = TextUtil.fillSpace(count, 2); // flash対応
        ret += '回数: x ${count}\n';
      }
      if(resists != null) {
        var value = resists.getValue(attr);
        if(value != 1.0) {
          ret += '属性: x ${value}\n';
        }
      }
      var sum = TextUtil.fillSpace(sum, 2); // flash対応
      ret += '---------- \n';
      if(count > 1) {
        ret += '最大';
      }
      else {
        ret += '計';
      }
      ret += ': ${sum}ダメージ\n';
      var hitratio = TextUtil.fillSpace(hitratio, 3); // flash対応
      ret += '(命中率: ${hitratio}%)';
    }
    else {
      ret += getDetail(item);
    }

    return ret;
  }

  /**
   * 無効なアイテムかどうか
   **/
  public static function isNone(id:ItemsKind):Bool {
    return id == ItemsKind.None;
  }

  /**
   * カテゴリを取得
   **/
  public static function getCategory(item:ItemData):ItemCategory {
    switch(ItemDB.getCategory(item.id)) {
      case Items_category.Portion:
        return ItemCategory.Portion;
      case Items_category.Weapon:
        return ItemCategory.Weapon;
    }
  }


  // ダメージ値取得
  public static function calcDamage(owner:SeqMgr, item:ItemData, bMultiple:Bool, resists:ResistList):Int {

    var data = BtlLogicFactory.createPlayerLogic(owner, item);
    var player = owner.player;
    var enemy = owner.enemy;
    var val = 0;
    switch(data.type) {
      case BtlLogic.Attack(type, prm):
        val = BtlCalc.damage(prm, player, enemy);
      default:
        // あり得ない
        throw 'Error: Invalid data.type = ${data}';
    }
    var count = 1;
    if(bMultiple) {
      // 複数回攻撃を含める
      count = getCount(item);
    }
    var sum = (val * count);

    return sum;
  }

  public static function getMin(item:ItemData):Int {
    return ItemDB.getMin(item.id);
  }

  public static function getMax(item:ItemData):Int {
    return ItemDB.getMax(item.id);
  }

  public static function getCount(item:ItemData):Int {
    var count = ItemDB.getCount(item.id);
    if(count == 0) {
      return 1;
    }
    return count;
  }

  public static function getHp(item:ItemData):Int {
    return ItemDB.getHp(item.id);
  }

  /**
   * アイテムを生成
   **/
  public static function add(itemid:ItemsKind):ItemData {
    var item = new ItemData();
    item.id = itemid;
    var min = getMin(item);
    var max = getMax(item);
    item.max = FlxG.random.int(min, max);
    item.now = item.max;

    return item;
  }
}
