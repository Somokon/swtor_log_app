package {
	import flash.utils.Dictionary;
	
	import mx.utils.StringUtil;
	
	/**
	 * An Actor represents either a player or an NPC in the game.
	 */
	public class Actor {
		
		public var name:String;
		
		private var _id:String; //Unique identifier
		
		private var _abilities:Dictionary = new Dictionary();
		
		public function Actor(id:String) {
			
			_id = id;
		}
		
		public function get id():String {
			
			return _id;
		}
		
		public function get abilities():Dictionary {
			
			return _abilities;
		}
		
		public function getAbility(token:String):Ability {
			
			var split:Vector.<String> = LogUtils.splitNameAndId(token);
			var id:String = split[1];
			
			if (_abilities[id] == null) {
				var ability:Ability = _abilities[id] = new Ability(id);
				ability.name =  split[0];
				_abilities[id] = ability;
			}
			
			return _abilities[id];
		}
	}
}