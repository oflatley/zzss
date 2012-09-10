package collision {

	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import interfaces.ICollisionData;
	
	import util.BitArray2D;
	import util.Vector2;
	
	
	
	public class CollisionData implements ICollisionData {

		private static var offset : int = 0;
		
		private var _accumA : int = 0;
		private var _accumB : int = 0;
		
		private var _$ : int = 500;
		

		public function testPoint( p : Point ) : Vector2 {
			
			return testxy( p.x, p.y );
	
			
			var x : int = Math.floor( p.x + .5 );
			var y : int = Math.floor( p.y + .5 );
			
			
			var vResult : Vector2 = null;
			
			if( _bits.contains(x,y) && _bits.testxy(x,y) ) {
				
				
				var xx : int;
				var yy : int;
				if( _bits.contains( x, y-1 ) ) {
					yy = _bits.findAbove( 0, x, y-1 );
				} else {
					yy = -1;
				}
				
				if( _bits.contains( x-1, y ) ) {
					xx = _bits.findLeft( 0, x-1, y );
				} else {
					xx = -1;
				}
				
				vResult = new Vector2(xx,yy);
			} 
			
			return vResult;
		
		
		}
		public function testxy( _x : Number, _y:Number ) : Vector2  {
			
			
			var ta0 : int = getTimer();
			{
//				for( var ii : int = 0; ii < 500; ++ii )
				var vResult : Vector2 = testxy1( _x, _y );
			}
			var ta1 : int = getTimer();
			
			var tb0 : int = getTimer();
			{
//				for( var jj : int = 0; jj < 500; ++jj )
				var _vResult : Vector2  = _testxy( _x, _y );			
			}
			var tb1 : int = getTimer();
			
			_accumA += (ta1-ta0);
			_accumB += (tb1-tb0);
			
			if( !_$-- ) {
				trace('asdfasdfggg');
			}
			
			
			if( !vResult && !_vResult )
				return null;
			
 			if( _vResult.y != vResult.y ) {
				throw new Error( 'pbbbt yyyy' );
			}
			
			if( _vResult.x != vResult.x ) {
				throw new Error( 'pbbbt xxxxx' );
			}
			
			return _vResult;
		}

		private function testxy1( _x : Number, _y : Number ) : Vector2 {

			var vResult : Vector2 = null;

			var x : int = Math.floor( _x + .5 );
			var y : int = Math.floor( _y + .5 );
			
			if( x < _bits.width && x >= 0 && y < _bits.height && y >= 0 && _bits.testxy(x,y) ) {
				
				// check up
				for( var yy : int = y - 1; yy >= 0 ; --yy  ) {
					if( ! _bits.testxy(x,yy) ) {
						break;
					}
				}
				
				// check left
				for( var xx : int = x - 1; xx >= 0 ; --xx  ) {
					if( ! _bits.testxy(xx,y) ) {
						break;
					}
				}
				vResult = new Vector2(xx-x,yy-y);
			}
			return vResult;
			
		}
		
		private function _testxy( _x : Number, _y:Number ) : Vector2 {
			
			var x : int = Math.floor( _x + .5 );
			var y : int = Math.floor( _y + .5 );

			
			var vResult : Vector2 = null;
			
			if( _bits.contains(x,y) && _bits.testxy(x,y) ) {
					
				
				var xx : int;
				var yy : int;
				if( _bits.contains( x, y-1 ) ) {
					yy = _bits.findAbove( 0, x, y-1 );
				} else {
					yy = -1;
				}
				
				if( _bits.contains( x-1, y ) ) {
					xx = _bits.findLeft( 0, x-1, y );
				} else {
					xx = -1;
				}
				
				vResult = new Vector2(xx,yy);
			} 
			
			return vResult;
			
		}
		
		
		public function CollisionData( w : uint, h : uint, v :Array  ) {
			_bits = new BitArray2D( w,h,v );
		}
		protected var _bits : BitArray2D;
	}
}