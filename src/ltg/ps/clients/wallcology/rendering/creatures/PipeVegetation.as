package ltg.ps.clients.wallcology.rendering.creatures {
	import ltg.ps.clients.wallcology.model.CreatureType;
	
	
	public class PipeVegetation extends Creature {
		
		[Bindable]
		public var bunchId:int;
		
		public function PipeVegetation() {
			super();
			this.type = CreatureType.SCUM;
			this.location = Location.PIPES;
		}
		
	}
}