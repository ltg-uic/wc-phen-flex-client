package ltg.ps.clients.wallcology.rendering.paths_handling {
	import flash.geom.Point;
	
	public class PipeScumWaypoint extends Point {
		
		public var bunchId:int = 0;
		
		public function PipeScumWaypoint(x:Number=0, y:Number=0, bid:int=0) {
			super(x, y);
			bunchId = bid;
		}
	}
}