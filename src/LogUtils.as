package
{
	import mx.utils.StringUtil;

	/**
	 * Various utility functions for working with the SWTOR combat log
	 */
	public class LogUtils {
		
		public static var ACTIVATE_ABILITY:String = "Event {836045448945472}: AbilityActivate {836045448945479}";
		public static var DEAL_DAMAGE:String = "ApplyEffect {836045448945477}: Damage {836045448945501}";
		public static var HEAL:String = "ApplyEffect {836045448945477}: Heal {836045448945500}";
		
		//Damage types
		public static var KINETIC_DAMAGE:String = "kinetic {836045448940873}";
		public static var ENERGY_DAMAGE:String = "energy {836045448940874}";
		public static var MISS_DAMAGE:String = "-miss {836045448945502}";
		
		//Enter/exit combat
		public static var ENTER_COMBAT:String = "Event {836045448945472}: EnterCombat {836045448945489}";
		public static var EXIT_COMBAT:String = "Event {836045448945472}: ExitCombat {836045448945490}";
		
		public static function splitNameAndId(str:String):Vector.<String> {
			
			var result:Vector.<String> = new Vector.<String>(2);
			var split:Array = str.split(" {");
			
			result[0] = StringUtil.trim(split[0]);
			result[1] = StringUtil.trim(split[1].replace("}", ""));
			
			return result;
		}
	}
}