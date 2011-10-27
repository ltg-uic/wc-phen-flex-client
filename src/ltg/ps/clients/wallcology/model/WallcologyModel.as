package ltg.ps.clients.wallcology.model {
	import flash.events.IEventDispatcher;
	
	import ltg.ps.clients.commons.Phenomena;
	
	[Bindable]
	public class WallcologyModel extends Phenomena {
		
		// Constants
		public static const HIGH_TEMP:int = 30;
		public static const LOW_TEMP:int = 20;
		public static const HIGH_LIGHT:int = 80;
		public static const LOW_LIGHT:int = 35;
		public static const HIGH_HUMID:int = 90;
		public static const LOW_HUMID:int = 50;
		// Client type & controls
		public var wallNId:int;
		public var pathID:int;
		public var isMicroworld:Boolean;
		public var isMicroworldRunning:Boolean = true;
		public var isTaggingEnabled:Boolean = false;
		public var isControlEnabled:Boolean = false;
		// Environment
		public var temperature:int;
		public var isTempHigh:Boolean;
		public var light:int;
		public var isLightHigh:Boolean;
		public var humidity:int;
		public var isHumidHigh:Boolean;
		// Population
		public var greenScum:int;
		public var fluffyMold:int;
		public var blueBug_s1:int;
		public var blueBug_s2:int;
		public var blueBug_s3:int;
		public var blueBug_s4:int;
		public var greenBug_s1:int;
		public var greenBug_s2:int;
		public var fuzzPredator_s1:int;
		public var fuzzPredator_s2:int;
		
		
		public function WallcologyModel(target:IEventDispatcher=null){
			super(target);
		}
		
		
		public function setWindowNumericId(username:String):void {
			wallNId = int(username.charAt(username.length-1));
			pathID = (wallNId-1) % 4;
		}
		
		
		/**
		 * Executed whenever the first update to the simulation is received.
		 */
		protected override function parseFirstXMLupdate(message:XML):void {
			// Client type stuff
			message.@type=="microworld" ? isMicroworld = true : isMicroworld = false;
			if(isMicroworld)
				message.@status=="running" ? isMicroworldRunning = true : isMicroworldRunning = false;
			// Environment
			parseEnvironment(message);
			// Population
			greenScum = message.population.greenScum; 
			fluffyMold = message.population.fluffyMold;
			blueBug_s1 = message.population.blueBug_s1;
			blueBug_s2 = message.population.blueBug_s2;
			blueBug_s3 = message.population.blueBug_s3;
			blueBug_s4 = message.population.blueBug_s4;
			greenBug_s1 = message.population.greenBug_s1;
			greenBug_s2 = message.population.greenBug_s2;
			fuzzPredator_s1 = message.population.fuzzPredator_s1;
			fuzzPredator_s2 = message.population.fuzzPredator_s2;
		}
		
		
		/**
		 * Executed whenever an update to the simulation is received.
		 */
		protected override function parseXMLupdate(message:XML):void {
			// Environment
			parseEnvironment(message);
			
			// Population (get new values)
			var tmpGreenScum:int = message.population.greenScum; 
			var tmpFluffyMold:int = message.population.fluffyMold;
			var tmpBlueBug_s1:int = message.population.blueBug_s1;
			var tmpBlueBug_s2:int = message.population.blueBug_s2;
			var tmpBlueBug_s3:int = message.population.blueBug_s3;
			var tmpBlueBug_s4:int = message.population.blueBug_s4;
			var tmpGreenBug_s1:int = message.population.greenBug_s1;
			var tmpGreenBug_s2:int = message.population.greenBug_s2;
			var tmpFuzzPredator_s1:int = message.population.fuzzPredator_s1;
			var tmpFuzzPredator_s2:int = message.population.fuzzPredator_s2;
			
			// Population (generate events based on deltas)
			
			// Scum
			var dScum:int = tmpGreenScum - greenScum; 
			if (dScum > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.SCUM_GEN_EVENT, dScum));
			else if (dScum < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.SCUM_EAT_EVENT,-dScum));
			
			// Fuzz 
			var dFuzz:int = tmpFluffyMold - fluffyMold; 
			if (dFuzz >0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.FUZZ_GEN_EVENT, dFuzz));
			else if (dFuzz < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.FUZZ_EAT_EVENT, -dFuzz));
			
			// Blue bugs
			var dBB_s1:int = tmpBlueBug_s1 - blueBug_s1;
			if(dBB_s1 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_LAYEGG_EVENT, dBB_s1));
			else if(dBB_s1 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_HATCH_EVENT, -dBB_s1));
			var dBB_s2:int = tmpBlueBug_s2 - blueBug_s2;
			if(dBB_s2 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_ADD_LARVA_EVENT, dBB_s2));
			else if(dBB_s2 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_KILL_LARVA_EVENT, -dBB_s2));
			var dBB_s3:int = tmpBlueBug_s3 - blueBug_s3;
			if(dBB_s3 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_PUPATE_EVENT, dBB_s3));
			else if(dBB_s3 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_SPLIT_EVENT, -dBB_s3));
			var dBB_s4:int = tmpBlueBug_s4 - blueBug_s4;
			if(dBB_s4 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_ADD_ADULT_EVENT, dBB_s4));
			else if(dBB_s4 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.BB_DIE_EVENT, -dBB_s4));
			
			// Green bugs 
			var dGB_s1:int = tmpGreenBug_s1 - greenBug_s1;
			if (dGB_s1 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.GB_LAYEGG_EVENT, dGB_s1));
			else if (dGB_s1 < 0) {
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.GB_HATCH_EVENT, -dGB_s1));
			var dGB_s2:int = tmpGreenBug_s2 - greenBug_s2;
			if (dGB_s2 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.GB_ADD_ADULT_EVENT, dGB_s2));
			else if (dGB_s2 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.GB_DIE_EVENT, -dGB_s2));
			}
			
			// Predator
			var dP_s1:int = tmpFuzzPredator_s1 - fuzzPredator_s1;
			if (dP_s1 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.P_S1_GEN_EVENT, dP_s1));
			else if (dP_s1 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.P_S1_DIE_EVENT, -dP_s1));
			var dP_s2:int = tmpFuzzPredator_s2 - fuzzPredator_s2;
			if (dP_s2 > 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.P_S2_GEN_EVENT, dP_s2));
			else if (dP_s2 < 0)
				dispatchEvent(new ModelChangedEvent(ModelChangedEvent.P_S2_DIE_EVENT, -dP_s2));
			
			// Store new values
			greenScum = tmpGreenScum;
			fluffyMold = tmpFluffyMold;
			blueBug_s1 = tmpBlueBug_s1;
			blueBug_s2 = tmpBlueBug_s2;
			blueBug_s3 = tmpBlueBug_s3;
			blueBug_s4 = tmpBlueBug_s4;
			greenBug_s1 = tmpGreenBug_s1;
			greenBug_s2 = tmpGreenBug_s2;
			fuzzPredator_s1 = tmpFuzzPredator_s1;
			fuzzPredator_s2 = tmpFuzzPredator_s2;
			
			// Dispatch new model changed event
			dispatchEvent(new ModelChangedEvent(ModelChangedEvent.MODEL_CHANGED_EVENT));
		}
		
		
		private function parseEnvironment(message:XML):void {
			message.environment.@enableEdit=="true" ? isControlEnabled = true : isControlEnabled = false;
			temperature = message.environment.temperature;
			light = message.environment.light;
			humidity = message.environment.humidity;
			if(temperature==HIGH_TEMP)	isTempHigh = true; 	else isTempHigh = false;
			if(light==HIGH_LIGHT) 		isLightHigh = true;	else isLightHigh = false;
			if(humidity==HIGH_HUMID)	isHumidHigh = true;	else isHumidHigh = false;
			addEnvironmentNoise();
		}
		
		
		private function addEnvironmentNoise():void {
			var t_stdev:int = 2;
			temperature += (t_stdev - Math.round(Math.random()*t_stdev*2));
			var l_stdev:int = 3;
			light += (l_stdev - Math.round(Math.random()*l_stdev*2));
			var h_stdev:int = 5;
			light += (h_stdev - Math.round(Math.random()*h_stdev*2));
		}
	
		
		public function setTemperature(t:int):void {
			temperature = t;
			if(temperature==HIGH_TEMP)	isTempHigh = true; 	else isTempHigh = false;
		}
		
		public function setLight(l:int):void {
			light = l;
			if(light==HIGH_LIGHT) isLightHigh = true;	else isLightHigh = false;
		}
		
		public function setHumidity(h:int):void {
			humidity = h;
			if(humidity==HIGH_HUMID) isHumidHigh = true;	else isHumidHigh = false;
		}
		
	}
}