package
{
	import flash.events.Event;
	
	public class ParserEvent extends Event {
		
		public static const PARSING_DONE:String = "parsing-done";
		
		public function ParserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event {
			
			var result:ParserEvent = new ParserEvent(type, bubbles, cancelable);
			
			return result;
		}
	}
}