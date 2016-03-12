package jp_2dgames.game;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
class Calc {

  static var _csv:CsvLoader;
  public static function loadCsv():Void {
    _csv = new CsvLoader();
    _csv.load("assets/data/enemy.csv");
  }

  public static function getPower():Float {
    return 1 + 1 * Gauge.power / 100;
  }

  public static function getDefense():Float {
    var lvShield = Gauge.defense;
    var ratio = 50 + (150 * lvShield / 100);
    return ratio;
  }

  /**
   * ダメージ量の計算
   **/
  public static function Damage(eid:Int):Int {
    var ratio = getDefense();
    var power = _csv.getInt(eid, "str");
    return Std.int(power / (ratio / 100));
  }

  /**
   * シールドへのダメージ量を取得する
   **/
  public static function DamageShield(eid:Int):Int {
    return _csv.getInt(eid, "shield");
  }

  /**
   * 残りターン数を取得する
   **/
  public static function Turn(eid):Int {
    var min = _csv.getInt(eid, "tmin");
    var max = _csv.getInt(eid, "tmax");
    return FlxG.random.int(min, max);
  }
}
