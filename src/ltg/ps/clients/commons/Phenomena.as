package ltg.ps.clients.commons {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.igniterealtime.xiff.events.MessageEvent;
	
	public class Phenomena extends EventDispatcher {
		
		//Constants
		public  static const PHEN_INIT:String 	  		= "phenInit";
		public  static const PHEN_UPDATE_DONE:String   	= "phenUpdateDone";
		private static const DEFAULT_STATE:String 		= "default";
		private static const UPDATED_STATE:String 		= "updated";
	
		// State
		private var state:String = DEFAULT_STATE;
		
		
		public function Phenomena(target:IEventDispatcher=null) {
			super(target);
		}
		
		
		/**
		 * Executed whenever an update is received from the server
		 */
		public function onUpdateReceived(e:MessageEvent): void {
			// Update the data
			var message:XML = new XML(e.data.body);
			if (state==DEFAULT_STATE) {
				parseFirstXMLupdate(message);
				state=UPDATED_STATE;
				// Propagate the first update which will trigger 
				// the change of state from connecting to rendering 
				dispatchEvent(new Event(PHEN_INIT));
			} else {
				parseXMLupdate(message);
				// Propagate all the other updates that can potentially trigger the change of state
				// from connecting to rendering when re-connecting
				dispatchEvent(new Event(PHEN_UPDATE_DONE));
			}
		}
		
		
		/**
		 * Executed whenever the first update to the simulation is received.
		 */
		protected function parseFirstXMLupdate(message:XML):void {
			// Subclasses need to override this function.
		}
		
		
		/**
		 * Executed whenever an update to the simulation is received.
		 */
		protected function parseXMLupdate(message:XML):void {
			// Subclasses need to override this function.
		}
		
	}
}