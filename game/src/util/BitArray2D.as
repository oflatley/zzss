package util
{
	public class BitArray2D extends BitArray
	{
		private var _width : int;
		private var _height : int;
		
		public function BitArray2D( width : uint, height : uint, v : Array )
		{
			_width = width;
			_height = height;
			super( v );
		}
		
		public function testxy( x : uint, y : uint ) : Boolean {
			return super.test( y*_width + x );
		}
		
		public function get width() : int {
			return _width;
		}
		
		public function get height() : int {
			return _height;
		}
		
	}
}