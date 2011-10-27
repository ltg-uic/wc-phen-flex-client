package ltg.ps.clients.wallcology.rendering.paths_handling {
	import flash.events.Event;
	
	import ltg.ps.clients.wallcology.rendering.creatures.MobileCreature;
	
	public class NewPathEvent extends Event {
	
		public static const NEW_PATH_EVENT:String = "endOfPathEvent";
		
		public var origin:MobileCreature;
		
		
		public function NewPathEvent(c:MobileCreature) {
			super(NEW_PATH_EVENT);
			this.origin = c;
		}
	}
}