package ltg.ps.clients.wallcology.rendering.creatures {
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import ltg.ps.clients.wallcology.rendering.paths_handling.EndOfPathError;
	
	import mx.core.UIComponent;
	import mx.effects.*;
	import mx.events.EffectEvent;

	public class Creature extends UIComponent {
		
		public static const SPLITTING_SPEED:int = 20000;
		
		[Bindable] 
		public var type:String;
		[Bindable] 
		public var location:String;
		[Bindable]
		public var mc:MovieClip;
		[Bindable]
		public var isUsed:Boolean = false;
		
		// Action target
		protected var actionTarget:Creature;
		
		
		public function hatchBlueBugEgg(target:MobileCreature):void {
			actionTarget = target;
			var ccp:Point = new Point(x, y);
			var tp:Point = target.currentPath.actualPath[target.currentPath.outAction];
			var seq:Sequence = new Sequence();
			// Align the target to the out waypoint so it's ready to leave
			seq.addChild(target.alignToPath(ccp, tp));
			var p:Parallel = new Parallel();
			// Hatch the egg...
			var seq1:Sequence = new Sequence();
			for (var i:int=0; i<mc.totalFrames; i++) {
				var pa:Pause = new Pause();
				pa.duration = 10000 / mc.totalFrames;
				pa.addEventListener(EffectEvent.EFFECT_END, advanceMC);
				seq1.addChild(pa);
			}
			p.addChild(seq1);
			//... and fade in the creature
			var f:Fade = new Fade(target);
			f.alphaFrom = 0; 
			f.alphaTo = 1;
			f.duration = 10000;
			p.addChild(f);
			seq.addChild(p);
			// Stop/Start legs
			p.addEventListener(EffectEvent.EFFECT_END, target.playWalking);
			p.addEventListener(EffectEvent.EFFECT_END, makeInVisible);
			// Walk back to path
			seq.addChild(target.moveFromTo(ccp, tp));
			//Walk rest of path
			var cp:int = target.currentPath.outAction;
			var np:int;
			while(true) {
				try {
					np = target.currentPath.getNextWaypoint(cp);
				} catch (e:EndOfPathError) {
					break;
				}
				seq.addChild(target.alignToPath(target.currentPath.actualPath[cp], target.currentPath.actualPath[np]));
				seq.addChild(target.moveFromTo(target.currentPath.actualPath[cp], target.currentPath.actualPath[np]));
				cp = np;
			}
			// Move out of screen
			var fp:Point = target.getClosestOutWaypoint(target.currentPath.actualPath[cp]);
			seq.addChild(target.alignToPath(target.currentPath.actualPath[cp], fp));
			seq.addChild(target.moveFromTo(target.currentPath.actualPath[cp], fp));
			seq.addEventListener(EffectEvent.EFFECT_END, disposeTargetHandler);
			seq.play();
		}
		
		
		public function splitPupa(target:MobileCreature):void {
			actionTarget = target;
			var seq:Sequence = new Sequence();
			// Crossfade the two cretures
			var p:Parallel = new Parallel();
			var f:Fade = new Fade(target);
			f.alphaFrom = 0; 
			f.alphaTo = 1;
			f.duration = SPLITTING_SPEED;
			p.addChild(f);
			var f1:Fade = new Fade(this);
			f1.alphaFrom = 1; 
			f1.alphaTo = 0;
			f1.duration = SPLITTING_SPEED;
			p.addChild(f1);
			p.addEventListener(EffectEvent.EFFECT_END, makeInVisible);
			p.addEventListener(EffectEvent.EFFECT_END, target.playWalking);
			seq.addChild(p);
			// Walk target out of screen
			var dest:Point = target.getClosestOutWaypoint(new Point(x, y));
			seq.addChild(target.alignToPath(new Point(x,y), dest));
			seq.addChild(target.moveFromTo(new Point(x,y), dest));
			seq.addEventListener(EffectEvent.EFFECT_END, disposeTargetHandler);
			seq.play();
		}
		
		
		
		public function hatchGreenBugEgg(target:MobileCreature):void {
			actionTarget = target;
			var seq:Sequence = new Sequence();
			var p:Parallel = new Parallel();
			// Hatch the egg...
			var seq1:Sequence = new Sequence();
			for (var i:int=0; i<mc.totalFrames; i++) {
				var pa:Pause = new Pause();
				pa.duration = 10000 / mc.totalFrames;
				pa.addEventListener(EffectEvent.EFFECT_END, advanceMC);
				seq1.addChild(pa);
			}
			p.addChild(seq1);
			//... and fade in the creature
			var f:Fade = new Fade(target);
			f.alphaFrom = 0; 
			f.alphaTo = 1;
			f.duration = 10000;
			p.addChild(f);
			p.addEventListener(EffectEvent.EFFECT_END, makeInVisible);
			p.addEventListener(EffectEvent.EFFECT_END, target.playWalking);
			seq.addChild(p);
			// Walk target out of screen
			var dest:Point = target.getClosestOutWaypoint(new Point(x, y));
			seq.addChild(target.alignToPath(new Point(x,y), dest));
			seq.addChild(target.moveFromTo(new Point(x,y), dest));
			seq.addEventListener(EffectEvent.EFFECT_END, disposeTargetHandler);
			seq.play();
		}
		
		
		protected function disposeTargetHandler (event:Event):void {
			isUsed = false;
			MobileCreature (actionTarget).disposeHandler(event);
		}
		
		
		private function advanceMC(event:EffectEvent):void {
			mc.nextFrame();
		}
		
		private function makeInVisible(event:EffectEvent):void {
			this.visible = false;
		}
		
		
	}
}