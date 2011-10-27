package ltg.ps.clients.wallcology.model {
	import flash.events.Event;
	
	public class ModelChangedEvent extends Event {
		
		public static const MODEL_CHANGED_EVENT:String = "modelChanged";
		
		public static const SCUM_EAT_EVENT:String = "eatScumEvent";
		public static const SCUM_GEN_EVENT:String = "genScumEvent";
		
		public static const FUZZ_GEN_EVENT:String = "genFuzzEvent";
		public static const FUZZ_EAT_EVENT:String = "eatFuzzEvent";
		
		public static const BB_LAYEGG_EVENT:String = "bbLayEvent";
		public static const BB_HATCH_EVENT:String = "bbHatchEvent";
		public static const BB_ADD_LARVA_EVENT:String = "bbAddLarva";
		public static const BB_KILL_LARVA_EVENT:String = "bbKillLarva";
		public static const BB_PUPATE_EVENT:String = "bbPupateEvent";
		public static const BB_SPLIT_EVENT:String = "bbSplitEvent";
		public static const BB_ADD_ADULT_EVENT:String = "bbAddAdult"
		public static const BB_DIE_EVENT:String = "bbDieEvent";
		
		public static const GB_LAYEGG_EVENT:String = "gbLayEvent";
		public static const GB_HATCH_EVENT:String = "gbHatchEvent";
		public static const GB_ADD_ADULT_EVENT:String = "gbAddAdult";
		public static const GB_DIE_EVENT:String = "gbDieEvent";
		
		public static const P_S1_GEN_EVENT:String = "ps1GenEvent";
		public static const P_S1_DIE_EVENT:String = "ps1DieEvent";
		public static const P_S2_GEN_EVENT:String = "ps2dGenEvent";
		public static const P_S2_DIE_EVENT:String = "ps2dDieEvent";
		
		
		public var quantity:int;
		
		public function ModelChangedEvent(type:String, q:int=0) {
			super(type, false, false);
			quantity = q;
		}
	}
}