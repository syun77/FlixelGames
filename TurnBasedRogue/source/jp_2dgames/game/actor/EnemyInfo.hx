package jp_2dgames.game.actor;

import jp_2dgames.lib.CsvLoader;

/**
 * AIの種類
 **/
enum EnemyAI {
  Stupid; // プレイヤーをそのまま狙う
  AStar;  // A*
}

/**
 * 飛行属性
 **/
enum EnemyFly {
  None; // なし
  Fly;  // 飛行
  Wall; // 壁抜け
}

/**
 * 敵情報
 **/
class EnemyInfo {

  static var _csv:CsvLoader;

  public static function load():Void {
    _csv = new CsvLoader();
    _csv.load(AssetPaths.CSV_ENEMY);
  }
  public static function unload():Void {
    _csv = null;
  }

  /**
   * 名前を取得する
   **/
  public static function getName(eid:Int):String {
    return _csv.getString(eid, "name");
  }

  /**
   * AIの種別を取得する
   **/
  public static function getAI(eid:Int):EnemyAI {
    return switch(_csv.getString(eid, "ai")) {
      case "stupid": EnemyAI.Stupid;
      default:       EnemyAI.Stupid;
    }
  }

  /**
   * 視界の範囲を取得する
   **/
  public static function getRange(eid:Int):Int {
    return _csv.getInt(eid, "range");
  }

  /**
   * 飛行属性を取得する
   **/
  public static function getFly(eid:Int):EnemyFly {
    return switch(_csv.getString(eid, "fly")) {
      case "fly":  EnemyFly.Fly;
      case "wall": EnemyFly.Wall;
      default:     EnemyFly.None;
    }
  }

  /**
   * 特殊パラメータを取得する
   **/
  public static function getExtra(eid:Int):String {
    return _csv.getString(eid, "ext");
  }
}
