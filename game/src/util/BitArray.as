package util
{
	public class BitArray
	{
		private var _data : Array; 
		
		public function BitArray( data : Array )
		{
			_data = data;			
		}
		
		public function test( _dx : uint ) : Boolean {
		
			return 0 != ( uint(_data[_dx>>>5]) & (0x80000000 >>> (_dx&31)) );
		}
	}
}