package ltg.ps.clients.wallcology.rendering.creatures {
	import flash.events.Event;
	
	public class DisposeCreatureEvent extends Event {
		
		public static const DISPOSE_CREATURE_EVENT:String = "disposeCreatureEvent";
		
		public var origin:Creature;
		
		public function DisposeCreatureEvent(c:Creature) {
			super(DISPOSE_CREATURE_EVENT);
			this.origin = c;
		}
	}
}