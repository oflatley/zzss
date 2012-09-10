package util
{
	public class BitArray2D extends BitArray
	{
		private var _width : int;
		private var _height : int;
		
		public function BitArray2D( width : uint, height : uint, v : Array  = null )
		{
			_width = width;
			_height = height;			
			super( width*height, v );
		}
		
		public function testxy( x : uint, y : uint ) : Boolean {
			return super.test( y*_width + x );
		}
		
		public function contains( x : uint, y : uint ) : Boolean {
			return( x < _width && y < _height );
		}
		
		
		public function findRight( _01 : int, x : uint, y : uint ) : int {
			var dx : uint = super.findFirst( _01, y*_width + x );
			
			if( -1 != dx ) {
				// is the found dx on the same row ?
				if( x + dx < _width ) {
					return dx;
				}
			}
			return -1;
		}
		
		public function findLeft( _01 : int, x : uint, y : uint ) : int {
			var dx : int = y * _width + x;
			var disp : int = super.findLast( _01, dx ) ;
			
			if( disp < x ) {
				return -(disp+1)
			}
			return -(x+2);
		}
		
		public function findAbove( _01 : int, x : uint, y : uint ) : int {
			var dx0 : uint = y * _width + x;
			var dx1 : int = super.findFirstWithStride( _01, -_width, dx0 );
			
			if( -1 == dx1 ) {
				return -(y+2);
			}
			
			var disp : Number = (dx0-dx1)/_width + 1;
			
			// debug -- assert disp is always an int, not a real
			{
				var idisp : int = int(disp);
				if( disp - idisp ) {
					throw new Error( 'i do not understand' );
				}
			}
			
			return -disp;
		}
		
		public function findBelow( _01 : int, x : uint, y : uint ) : int {
			var dx : uint = super.findFirstWithStride( _01, _width, y*_width + x );
			return dx;			
		}
		
		// DEPRECATE -- extend functionity of testxy -- improve client calling also with super.findIndexFirstOne etc
		public function get width() : int {
			return _width;
		}
		
		// DEPRECATE -- extend functionity of testxy
		public function get height() : int {
			return _height;
		}
	
		
	}
}