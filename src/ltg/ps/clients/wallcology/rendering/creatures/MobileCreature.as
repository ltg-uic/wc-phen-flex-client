package ltg.ps.clients.wallcology.rendering.creatures {
	import flash.events.Event;
	import flash.geom.Point;
	
	import ltg.ps.clients.wallcology.model.CreatureType;
	import ltg.ps.clients.wallcology.rendering.paths_handling.CreaturePath;
	import ltg.ps.clients.wallcology.rendering.paths_handling.EndOfPathError;
	import ltg.ps.clients.wallcology.rendering.paths_handling.NewPathEvent;
	import ltg.ps.clients.wallcology.rendering.paths_handling.PathDirection;
	
	import mx.effects.Fade;
	import mx.effects.Parallel;
	import mx.effects.Pause;
	import mx.effects.Sequence;
	import mx.events.EffectEvent;
	
	import spark.effects.Move;
	import spark.effects.Rotate;
	
	public class MobileCreature extends Creature {
		
		public static const  BLUE_BUG_S2_SPEED:Number  	= 13;
		public static const  BLUE_BUG_S4_SPEED:Number  	= 13;
		public static const  GREEN_BUG_S2_SPEED:Number  = 15;
		public static const  PREDATOR_S1_SPEED:Number  	= 16;
		public static const  PREDATOR_S2_SPEED:Number  	= 18;
		
		public static const  FEED_SPEED:Number = 10000;
		public static const  PUPATING_SPEED:Number = 20000;
		
		[Bindable]
		public var currentPath:CreaturePath;
		[Bindable]
		public var currentPosition:int;
		[Bindable]
		public var currentAngle:Number = 0;
		[Bindable]
		public var flipped:Boolean = false;
		[Bindable]
		public var isZombie:Boolean = false;
		public var speed:Number;
		public var actionPath:CreaturePath;
		
		
		
		public function initializeCreature(origin:String):void {
			assignSpeed();
			orientateCreature();
			if (origin == Location.INSIDE_WALLSCOPE)
				currentPosition = currentPath.getRandomFirstWaypoint();
			else if (origin == Location.OUTSIDE_WALLSCOPE)
				currentPosition = currentPath.getFirstWaypoint();
			x = currentPath.actualPath[currentPosition].x;
			y = currentPath.actualPath[currentPosition].y;
		}
		
		
		public function initializeDisposableCreature(w:Number, h:Number):void {
			assignSpeed();
			orientateCreature();
			positionRandomlyOutstideScopeWall(w,h);
		}
		
		
		/**
		 * Executed when the walk ends, at the end of the path, outside the screen
		 */
		private function reInitializeCreature(event:Event = null):void {
			if (isZombie) {
				dispatchEvent(new DisposeCreatureEvent(this));	
			} else {
				dispatchEvent(new NewPathEvent(this));
				orientateCreature();
				currentPosition = currentPath.getFirstWaypoint();
				var fp:Point = getClosestOutWaypoint(currentPath.actualPath[currentPosition]);
				x = fp.x;
				y = fp.y;
				var sequence:Sequence = new Sequence();
				sequence.addChild(alignToPath(fp,currentPath.actualPath[currentPosition]));
				sequence.addChild(moveFromTo(fp, currentPath.actualPath[currentPosition]));
				buildMovement(sequence);
			}
		}
		
		
		public function buildMovement(seq:Sequence=null):void {
			var cp:int;
			var np:int;
			if (seq==null)
				seq = new Sequence();
			cp = currentPosition;
			// For each waypoint create a move object and sequence it
			while(true) {
				try {
					np = currentPath.getNextWaypoint(cp);
				} catch (e:EndOfPathError) {
					break;
				}
				seq.addChild(alignToPath(currentPath.actualPath[cp], currentPath.actualPath[np]));
				seq.addChild(moveFromTo(currentPath.actualPath[cp], currentPath.actualPath[np]));
				// Increment the point
				cp = np;
			}
			// Move out of screen
			var fp:Point = getClosestOutWaypoint(currentPath.actualPath[cp]);
			seq.addChild(alignToPath(currentPath.actualPath[cp], fp));
			seq.addChild(moveFromTo(currentPath.actualPath[cp], fp));
			seq.addEventListener(EffectEvent.EFFECT_END, reInitializeCreature);
			seq.play();
		}
		
		
		private function buildEatWallVegetationAnimation():void {
			var seq1:Sequence = new Sequence();
			var np:Point = new Point(actionTarget.x, actionTarget.y);
			var cp:Point = new Point(x, y);
			// Align to patch
			seq1.addChild(alignToPath(cp, np));
			// Move mouth over patch
			var D:Number = Point.distance(cp, np);
			var X:Number = np.x - cp.x;
			var Y:Number = np.y - cp.y;
			var d:Number = mc.width/2;
			var nnp:Point = new Point(np.x-d*X/D, np.y-d*Y/D);
			seq1.addChild(moveFromTo(cp, nnp));
			// Make patch disappear
			var f:Fade = new Fade(actionTarget);
			f.alphaFrom = 1; 
			f.alphaTo = 0;
			f.duration = FEED_SPEED;
			// Stop/Start legs
			f.addEventListener(EffectEvent.EFFECT_START, stopWalking);
			f.addEventListener(EffectEvent.EFFECT_END, playWalking);
			f.addEventListener(EffectEvent.EFFECT_END, makeTargetInvisible);
			seq1.addChild(f);
			// Walk out
			var cpp:Point = getClosestOutWaypoint(nnp);
			seq1.addChild(alignToPath(nnp,cpp));
			seq1.addChild(moveFromTo(nnp,cpp));
			// Destroy
			seq1.addEventListener(EffectEvent.EFFECT_END, disposeHandler);
			seq1.play();
		}
		
		
		private function buildEatPipeVegetationAnimation():void {
			currentPosition = actionPath.getFirstWaypoint();
			var fp:Point = getClosestOutWaypoint(actionPath.actualPath[currentPosition]);
			// Move out of screen close to beginning of action path
			x = fp.x;
			y = fp.y;
			var seq:Sequence = new Sequence();
			seq.addChild(alignToPath(fp,actionPath.actualPath[currentPosition]));
			seq.addChild(moveFromTo(fp, actionPath.actualPath[currentPosition]));
			// For each waypoint create a move object and sequence it
			var cp:int;
			var np:int;
			cp = currentPosition;
			var j:int = 0;
			while(j < actionPath.inAction) {
				np = actionPath.getNextWaypoint(cp);
				seq.addChild(alignToPath(actionPath.actualPath[cp], actionPath.actualPath[np]));
				seq.addChild(moveFromTo(actionPath.actualPath[cp], actionPath.actualPath[np]));
				cp = np;
				j++;
			}
			var tp:Point = new Point(actionTarget.x, actionTarget.y);
			// Align to patch
			seq.addChild(alignToPath(actionPath.actualPath[cp], tp));
			// Move mouth to actionTarget
			var D:Number = Point.distance(actionPath.actualPath[cp], tp);
			var X:Number = tp.x - actionPath.actualPath[cp].x;
			var Y:Number = tp.y - actionPath.actualPath[cp].y;
			var d:Number = mc.width/2;
			var nnp:Point = new Point(tp.x-d*X/D, tp.y-d*Y/D);
			seq.addChild(moveFromTo(actionPath.actualPath[cp], nnp));
			// Make patch disappear
			var f:Fade = new Fade(actionTarget);
			f.alphaFrom = 1; 
			f.alphaTo = 0;
			f.duration = FEED_SPEED;
			// Stop/Start legs
			f.addEventListener(EffectEvent.EFFECT_START, stopWalking);
			f.addEventListener(EffectEvent.EFFECT_END, playWalking);
			f.addEventListener(EffectEvent.EFFECT_END, makeTargetInvisible);
			seq.addChild(f);
			// Walk back to path
			np = actionPath.getNextWaypoint(cp);
			seq.addChild(alignToPath(nnp, actionPath.actualPath[np]));
			seq.addChild(moveFromTo(nnp, actionPath.actualPath[np]));
			cp = np;
			//Walk rest of path
			while(true) {
				try {
					np = actionPath.getNextWaypoint(cp);
				} catch (e:EndOfPathError) {
					break;
				}
				seq.addChild(alignToPath(actionPath.actualPath[cp], actionPath.actualPath[np]));
				seq.addChild(moveFromTo(actionPath.actualPath[cp], actionPath.actualPath[np]));
				cp = np;
			}
			// Move out of screen
			fp = getClosestOutWaypoint(actionPath.actualPath[cp]);
			seq.addChild(alignToPath(actionPath.actualPath[cp], fp));
			seq.addChild(moveFromTo(actionPath.actualPath[cp], fp));
			seq.addEventListener(EffectEvent.EFFECT_END, disposeHandler);
			seq.play();
		}		
		
		
		private function buildBlueBugLayEggAnimation():void {
			// First, set egg's alpha to 0 and visibility to true
			actionTarget.alpha = 0;
			actionTarget.visible = true;
			currentPosition = actionPath.getFirstWaypoint();
			var fp:Point = getClosestOutWaypoint(actionPath.actualPath[currentPosition]);
			// Move out of screen close to beginning of action path
			x = fp.x;
			y = fp.y;
			var seq:Sequence = new Sequence();
			seq.addChild(alignToPath(fp,actionPath.actualPath[currentPosition]));
			seq.addChild(moveFromTo(fp, actionPath.actualPath[currentPosition]));
			// For each waypoint create a move object and sequence it
			var cp:int;
			var np:int;
			cp = currentPosition;
			var j:int = 0;
			while(j < actionPath.inAction) {
				np = actionPath.getNextWaypoint(cp);
				seq.addChild(alignToPath(actionPath.actualPath[cp], actionPath.actualPath[np]));
				seq.addChild(moveFromTo(actionPath.actualPath[cp], actionPath.actualPath[np]));
				cp = np;
				j++;
			}
			var tp:Point = new Point(actionTarget.x, actionTarget.y);
			// Align and move to egg location
			seq.addChild(alignToPath(actionPath.actualPath[cp], tp));
			seq.addChild(moveFromTo(actionPath.actualPath[cp], tp));
			// Pause for 5 seconds
			var pa:Pause = new Pause();
			pa.duration = 5000;
			seq.addChild(pa);
			// Stop legs
			pa.addEventListener(EffectEvent.EFFECT_START, stopWalking);
			// Make egg appear
			var f:Fade = new Fade(actionTarget);
			f.alphaFrom = 0; 
			f.alphaTo = 1;
			f.duration = 100;
			seq.addChild(f);
			// Pause for 3 more seconds
			var pa2:Pause = new Pause();
			pa2.duration = 3000;
			seq.addChild(pa2);
			// Start walking again
			pa2.addEventListener(EffectEvent.EFFECT_END, playWalking);
			// Walk back to path
			np = actionPath.getNextWaypoint(cp);
			seq.addChild(alignToPath(tp, actionPath.actualPath[np]));
			seq.addChild(moveFromTo(tp, actionPath.actualPath[np]));
			cp = np;
			//Walk rest of path
			while(true) {
				try {
					np = actionPath.getNextWaypoint(cp);
				} catch (e:EndOfPathError) {
					break;
				}
				seq.addChild(alignToPath(actionPath.actualPath[cp], actionPath.actualPath[np]));
				seq.addChild(moveFromTo(actionPath.actualPath[cp], actionPath.actualPath[np]));
				cp = np;
			}
			// Move out of screen
			fp = getClosestOutWaypoint(actionPath.actualPath[cp]);
			seq.addChild(alignToPath(actionPath.actualPath[cp], fp));
			seq.addChild(moveFromTo(actionPath.actualPath[cp], fp));
			seq.addEventListener(EffectEvent.EFFECT_END, disposeHandler);
			seq.play();
		}
		
		
		private function buildPupatingAnimation():void {
			// First, set pupa's alpha to 0 and visibility to true
			actionTarget.alpha = 0;
			actionTarget.visible = true;
			// Start creating the sequence
			var seq1:Sequence = new Sequence();
			var np:Point = new Point(actionTarget.x, actionTarget.y); 
			var cpp:Point = new Point(x, y);
			// Align and move over pupa
			seq1.addChild(alignToPath(cpp, np));
			seq1.addChild(moveFromTo(cpp, np));
			// Rotate larva in vertical position
			var ro:Rotate = new Rotate(this);
			ro.angleFrom = currentAngle;
			ro.angleTo = -90;
			ro.duration = 1000;
			seq1.addChild(ro);
			// Fade us away and pupa in
			var p:Parallel = new Parallel();
			var f:Fade = new Fade(actionTarget);
			f.alphaFrom = 0; 
			f.alphaTo = 1;
			f.duration = PUPATING_SPEED;
			p.addChild(f);
			var f1:Fade = new Fade(this);
			f1.alphaFrom = 1; 
			f1.alphaTo = 0;
			f1.duration = PUPATING_SPEED;
			p.addChild(f1);
			seq1.addChild(p);
			// Stop legs of larva when it gets to pupa location 
			p.addEventListener(EffectEvent.EFFECT_START, stopWalking);
			// Walk out
			var cp:Point = getClosestOutWaypoint(np);
			seq1.addChild(moveFromTo(np,cp));
			// Reset alpha
			var f2:Fade = new Fade(this);
			f2.alphaFrom = 0; 
			f2.alphaTo = 1;
			f2.duration = 100;
			seq1.addChild(f2);
			// Destroy
			seq1.addEventListener(EffectEvent.EFFECT_END, disposeHandler);
			seq1.play();
		}
		
		
		private function buildGreenBugLayEggAnimation():void {
			// First, set egg's alpha to 0 and visibility to true
			actionTarget.alpha = 0;
			actionTarget.visible = true;
			// Start creating the sequence
			var seq:Sequence = new Sequence();
			var cpp:Point = new Point(x, y);
			var np:Point = new Point(actionTarget.x, actionTarget.y); 
			// Align and move over egg laying location
			seq.addChild(alignToPath(cpp, np));
			seq.addChild(moveFromTo(cpp, np));
			// Pause for 5 seconds
			var pa:Pause = new Pause();
			pa.duration = 5000;
			seq.addChild(pa);
			// Stop legs
			pa.addEventListener(EffectEvent.EFFECT_START, stopWalking);
			// Make egg appear
			var f:Fade = new Fade(actionTarget);
			f.alphaFrom = 0; 
			f.alphaTo = 1;
			f.duration = 100;
			seq.addChild(f);
			// Pause for 3 more seconds
			var pa2:Pause = new Pause();
			pa2.duration = 3000;
			seq.addChild(pa2);
			// Start walking again
			pa2.addEventListener(EffectEvent.EFFECT_END, playWalking);
			// Walk out
			var cp:Point = getClosestOutWaypoint(np);
			seq.addChild(alignToPath(np, cp));
			seq.addChild(moveFromTo(np,cp));
			// Destroy
			seq.addEventListener(EffectEvent.EFFECT_END, disposeHandler);
			seq.play();
		}
		
		
		
		public function playWalking(event:EffectEvent):void {
			mc.play();
		}
		
		
		public function stopWalking(event:EffectEvent):void {
			mc.stop();
		}
	

		
		public function moveFromTo(cp:Point, np:Point):Move {
			var m:Move = new Move(this);
			m.xFrom = cp.x;
			m.yFrom = cp.y;
			m.xTo = np.x;
			m.yTo = np.y;
			m.duration = Point.distance(cp, np) * speed;
			return m;
		}
		
		
		public function alignToPath(cp:Point, np:Point):Rotate {
			var r:Rotate = new Rotate(this);
			r.autoCenterTransform = true;
			r.angleFrom = currentAngle;
			var pa:Number = 0;
			// Assign final angle
			if (currentPath.up == "L" && currentPath.direction==PathDirection.FORWARD) {  // check
				r.angleTo = Math.atan2(np.y-cp.y, np.x-cp.x) * 180 / Math.PI;
			} else if (currentPath.up == "L" && currentPath.direction==PathDirection.BACKWARD) {
				pa = Math.atan2(np.y-cp.y, np.x-cp.x) * 180 / Math.PI;
				if (pa-180 < -180)
					r.angleTo = pa + 180;
				else
					r.angleTo = pa - 180;
			} else if (currentPath.up == "R" && currentPath.direction==PathDirection.FORWARD) {
				pa = Math.atan2(np.y-cp.y, np.x-cp.x) * 180 / Math.PI;
				if (pa-180 < -180)
					r.angleTo = pa + 180;
				else
					r.angleTo = pa - 180;
			} else if (currentPath.up == "R" && currentPath.direction==PathDirection.BACKWARD) {
				r.angleTo = Math.atan2(np.y-cp.y, np.x-cp.x) * 180 / Math.PI;
			} else if (currentPath.up == "" && currentPath.direction==PathDirection.FORWARD) {
				r.angleTo = Math.atan2(np.y-cp.y, np.x-cp.x) * 180 / Math.PI;
			} else if (currentPath.up == "" && currentPath.direction==PathDirection.BACKWARD) {
				pa = Math.atan2(np.y-cp.y, np.x-cp.x) * 180 / Math.PI;
				if (pa-180 < -180)
					r.angleTo = pa + 180;
				else
					r.angleTo = pa - 180;
			}
			r.duration = Math.abs(r.angleFrom - r.angleTo)*3;
			currentAngle = r.angleTo;
			return r;
		}
		
		
		public function eatFuzz(target:Creature):void {
			actionTarget = target;
			buildEatWallVegetationAnimation();
		}
		
		
		public function eatScum(target:Creature):void {
			actionTarget = target;
			buildEatWallVegetationAnimation();
		}
		
		
		public function eatPipeScum(target:Creature, path:CreaturePath):void {
			actionTarget = target;
			actionPath = path;
			buildEatPipeVegetationAnimation();
		}
		
		
		public function layBlueBugEgg(target:Creature, path:CreaturePath):void {
			actionTarget = target;
			actionPath = path;
			buildBlueBugLayEggAnimation();
		}
		
		
		public function pupate(target:Creature):void {
			actionTarget = target;
			buildPupatingAnimation();
		}
		
		
		public function layGreenBugEgg(target:Creature):void {
			actionTarget = target;
			buildGreenBugLayEggAnimation();
		}
		
		
		public function makeTargetInvisible (event:Event):void {
			actionTarget.visible = false;
		}
		
		
		public function disposeHandler (event:Event):void {
			if (actionTarget != null)
				actionTarget.isUsed = false;
			dispatchEvent(new DisposeCreatureEvent(this));
		}
		
		
		public function getClosestOutWaypoint(cp:Point):Point {
			// Find the edge closes to cp waypoint
			var min:Number = Math.min(cp.x, cp.y, 
				parent.width - cp.x, parent.height - cp.y);
			// Point out on the left
			if (min == cp.x) {
				return new Point(-mc.width, cp.y);
			// Point out on the top
			} else if (min == cp.y) {
				return new Point(cp.x, -mc.height);
			// Point out on the right
			} else if (min == parent.width - cp.x) {
				return new Point(parent.width+mc.width, cp.y);
			// Point out on the bottom
			} else if (min == parent.height - cp.y) {
				return new Point(cp.x, parent.height+mc.height);
			// Error
			} else
				throw new Error("This is impossible");
		}
		
		
		protected function positionRandomlyOutstideScopeWall(w:Number, h:Number):void {
			var xx:Number;
			var yy:Number;
			xx = Math.random()*w;
			yy = Math.random()*h;
			var p:Point = getClosestOutWaypoint(new Point(xx,yy));
			this.x = p.x;
			this.y = p.y;
		}
		
		
		protected function assignSpeed():void {
			switch(type) {
				case CreatureType.BB2:
					speed = BLUE_BUG_S2_SPEED;
					break;
				case CreatureType.BB4:
					speed = BLUE_BUG_S4_SPEED;
					break;
				case CreatureType.GB2:
					speed = GREEN_BUG_S2_SPEED;
					break;
				case CreatureType.P1:
					speed = PREDATOR_S1_SPEED;
					break;
				case CreatureType.P2:
					speed = PREDATOR_S2_SPEED;
					break;
			}
		}
		
		
		protected function orientateCreature():void {
			if (currentPath.up == "L" && currentPath.direction == PathDirection.FORWARD && flipped==false) {
				mc.scaleX*=-1;
				currentAngle = 180;
				flipped = true;
				return; 
			}
			if (currentPath.up == "R" && currentPath.direction == PathDirection.FORWARD && flipped==true) {
				mc.scaleX*=-1;
				currentAngle = 0;
				flipped = false;
				return; 
			}
			if (currentPath.up == "L" && currentPath.direction == PathDirection.BACKWARD && flipped==false) {
				return;
			}
			if (currentPath.up == "R" && currentPath.direction == PathDirection.BACKWARD && flipped==false) { 
				mc.scaleX*=-1;
				currentAngle = 180;
				flipped = true;
				return;
			}
			if (currentPath.up == "R" && currentPath.direction == PathDirection.FORWARD && flipped==false) {
				return;
			} 
			// Top view creatures
			if(currentPath.up == "" && currentPath.direction == PathDirection.FORWARD && flipped==false) {
				mc.scaleX*=-1;
				currentAngle = 0;
				flipped = true;
				return;
			}
			if(currentPath.up == "" && currentPath.direction == PathDirection.BACKWARD && flipped==false) {
				return;
			}
		}
	}
}