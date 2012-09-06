package util
{
	import flash.geom.Point;

	public class Vector2
	{
		private var _x : Number;
		private var _y : Number;
		
		public function Vector2( x:Number = 0, y : Number = 0)
		{
			setxy(x,y);
		}
		
		public static function subtract( vA : Vector2, vB : Vector2 ) : Vector2{
			return new Vector2( vB.x - vA.x, vB.y - vA.y );
		}
		
		public function get isNotZero() : Boolean {
			return _x || _y;
		}
		
		public function setxy( x : Number, y : Number ) : void {
			_x = x;
			_y = y;
		}
		
		public function dot( v : Vector2 ) : Number {
			return _x * v.x + _y * v.y;
		}
		
		public function get x():Number 
		{			
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;	
		}
		
		public function get y():Number { 
			return _y;				
		}

		public function set y(value:Number):void 
		{
			_y = value;	
		}
				
		public function magnitudeSquared() : Number {
			return _x * _x + _y * _y;
		}
		
		public function magnitude() : Number {
			return Math.sqrt( _x * _x + _y * _y );
		}
		
		public function negate() : void {
			_x = -_x;
			_y = -_y;
		}
		
		public function scale( n : Number ) : void {
			_x *= n;
			_y *= n;
		}
		
		public function normalize() : void {
			var magn : Number = magnitude();
			_x /= magn;
			_y /= magn;
		}
	}
}