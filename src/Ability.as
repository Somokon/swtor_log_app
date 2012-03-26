package {
	
	public class Ability {
		
		private var _id:String;
		
		public var name:String;
		public var timesActivated:int = 0;
		public var timesTicked:int = 0;
		public var timesCrit:int = 0;
		
		public var totalDamage:int = 0;
		public var totalHeal:int = 0;
		
		private var _maxDamage:int;
		private var _minDamage:int;
		private var _maxHeal:int;
		private var _minHeal:int;
		
		private var _doesDamage:Boolean = false;
		private var _doesHeal:Boolean = false;
		
		public function Ability(id:String) {
			
			_id = id;
		}
		
		public function addDamage(value:int):void {
			
			_doesDamage = true;
			
			if (value > _maxDamage || !_maxDamage)
				_maxDamage = value;
			if (value < _minDamage || !_minDamage)
				_minDamage = value;
			
			totalDamage += value;
		}
		
		public function get maxDamage():int {
			
			return _maxDamage;
		}
		
		public function get minDamage():int {
			
			return _minDamage;
		}
		
		public function addHeal(value:int):void {
			
			_doesHeal = true;
			
			if (value > _maxHeal || !_maxHeal)
				_maxHeal = value;
			if (value < _minHeal || !_minHeal)
				_minHeal = value;
			
			totalHeal += value;
		}
		
		public function get maxHeal():int {
			
			return _maxHeal;
		}
		
		public function get minHeal():int {
			
			return _minHeal;
		}
		
		
		public function get doesDamage():Boolean {
			
			return _doesDamage;
		}
		
		
		public function get doesHeal():Boolean {
			
			return _doesHeal;
		}
	}
}