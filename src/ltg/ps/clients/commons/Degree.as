package ltg.ps.clients.commons {
	
	public class Degree {
		
		private var _value:Number;
		
		
		public function Degree(value:Number=0) { 
			_value = normalize(value);
		}
		
		
		public function normalize(v:Number):Number {
			// Normalize it
			v = v % 360;
			// Change sign if necessary
			if(v<0)
				return 360+v;
			return v;
		}
		
		
		public function add(v:Degree):Degree {
			return new Degree(_value + v.value);
		}
		
		
		/**
		 * Subtracts the value of the parameter from the value of this degree.
		 */
		public function sub(v:Degree):Degree {
			return new Degree(_value - v.value);
		}
		
		
		public function get value():Number {return _value;}
		
		
		public function toString():String {
			return value.toString();
		}
	
	
	}
}