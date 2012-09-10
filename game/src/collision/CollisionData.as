package collision {

	import flash.geom.Point;
	
	import interfaces.ICollisionData;
	
	import util.BitArray2D;
	import util.Vector2;
	
	
	
	public class CollisionData implements ICollisionData {

		private static var offset : int = 0;
		

		public function testPoint( p : Point ) : Vector2 {
			return testxy( p.x, p.y );
		}
		public function testxy( _x : Number, _y:Number ) : Vector2  {

	//		_x = offset;
	//		_y = 1 ; //offset=++ ; //offsetx++;
	//		offset++;
			
			
			var x : int = Math.floor( _x + .5 );
			var y : int = Math.floor( _y + .5 );
			var vResult : Vector2 = null;

			if( x == 33 && y == 22 ) {
				trace('dsfsdf');
			}
			
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
			
			var _vResult : Vector2  = _testxy( _x, _y );			

			if( !vResult && !_vResult )
				return null;
			
  			//if( _vResult.x != vResult.x || _vResult.y != vResult.y ) {
			if( _vResult.y != vResult.y ) {
				throw new Error( 'pbbbt yyyy' );
				//trace( 'pbbt: ');
			}
			
			if( _vResult.x != vResult.x ) {
				throw new Error( 'pbbbt xxxxx' );
				trace('pbbbbt x');
			}
			
			return _vResult;
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