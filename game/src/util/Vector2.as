package util
{
	import flash.geom.Point;

	public class Vector2
	{
		private var _p:Point;
		
		public function Vector2( x:Number = 0, y : Number = 0)
		{
			trace( x + ' -- ' + y );
			_p = new Point( x,y );
			trace( this.x + ' -- ' + this.y );
		}
		
		public static function subtract( vA : Vector2, vB : Vector2 ) : Vector2{
			return new Vector2( vB.x - vA.x, vB.y - vA.y );
		}
		
		public function get isNotZero() : Boolean {
			return _p.x || _p.y;
		}
		
		public function setxy( x : Number, y : Number ) : void {
			_p.x = x;
			_p.y = y;
		}
		
		public function dot( v : Vector2 ) : Number {
			return _p.x * v.x + _p.y * v.y;
		}
		
		public function get x():Number 
		{			
			return _p.x;
		}
		
		public function set x(value:Number):void 
		{
			_p.x = value;	
		}
		
		public function get y():Number { 
			return _p.y;				
		}

		public function set y(value:Number):void 
		{
			_p.y = value;	
		}
				
		public function magnitudeSquared() : Number {
			return _p.x * _p.x + _p.y * _p.y;
		}
		
		public function magnitude() : Number {
			return Math.sqrt( _p.x * _p.x + _p.y * _p.y );
		}
		
		public function negate() : void {
			_p.x = -_p.x;
			_p.y = -_p.y;
		}
		
		public function scale( n : Number ) : void {
			_p.x *= n;
			_p.y *= n;
		}
		
		public function normalize() : void {
			var magn : Number = magnitude();
			_p.x /= magn;
			_p.y /= magn;
		}
	}
}